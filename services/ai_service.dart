import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';

class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<List<Question>> generateQuestions({
    required String content,
    required String subject,
    required int numberOfQuestions,
    required List<QuestionType> questionTypes,
    required DifficultyLevel difficulty,
  }) async {
    try {
      List<String> contentChunks = _splitContent(content);
      List<Question> allQuestions = [];

      for (String chunk in contentChunks) {
        final questionsFromChunk = await _generateQuestionsFromChunk(
          chunk: chunk,
          subject: subject,
          numberOfQuestions: (numberOfQuestions / contentChunks.length).ceil(),
          questionTypes: questionTypes,
          difficulty: difficulty,
        );
        allQuestions.addAll(questionsFromChunk);
      }

      allQuestions.shuffle();
      return allQuestions.take(numberOfQuestions).toList();
    } catch (e) {
      throw Exception('Failed to generate questions: $e');
    }
  }

  Future<List<Question>> _generateQuestionsFromChunk({
    required String chunk,
    required String subject,
    required int numberOfQuestions,
    required List<QuestionType> questionTypes,
    required DifficultyLevel difficulty,
  }) async {
    final prompt = _buildPrompt(
      content: chunk,
      subject: subject,
      numberOfQuestions: numberOfQuestions,
      questionTypes: questionTypes,
      difficulty: difficulty,
    );

    final response = await _makeAIRequest(prompt);
    return _parseAIResponse(response, subject, difficulty);
  }

  String _buildPrompt({
    required String content,
    required String subject,
    required int numberOfQuestions,
    required List<QuestionType> questionTypes,
    required DifficultyLevel difficulty,
  }) {
    final typeDescriptions = questionTypes
        .map((type) {
          switch (type) {
            case QuestionType.multipleChoice:
              return 'multiple choice (4 options, only one correct)';
            case QuestionType.trueFalse:
              return 'true/false';
            case QuestionType.enumeration:
              return 'enumeration (list multiple correct answers)';
          }
        })
        .join(', ');

    return '''
Generate $numberOfQuestions educational questions based on the following content. 

Subject: $subject
Difficulty Level: ${difficulty.name}
Question Types: $typeDescriptions

Content:
$content

Please generate questions in the following JSON format:
{
  "questions": [
    {
      "type": "multipleChoice", // or "trueFalse" or "enumeration"
      "text": "Question text here",
      "options": ["Option A", "Option B", "Option C", "Option D"], // For multiple choice only
      "correctAnswer": "Correct answer text",
      "correctAnswers": ["Answer 1", "Answer 2"], // For enumeration only
      "explanation": "Brief explanation of the answer"
    }
  ]
}

Guidelines:
- Make questions clear and unambiguous
- Ensure correct answers are factually accurate based on the content
- For multiple choice: provide 4 options with only one correct
- For enumeration: ask for a list of items/concepts
- Include brief explanations for educational value
- Vary question difficulty as appropriate for ${difficulty.name} level
''';
  }

  Future<String> _makeAIRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an educational AI that generates high-quality quiz questions from provided content. Always respond with valid JSON.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('AI service error: ${response.statusCode}');
      }
    } catch (e) {
      return _generateSampleQuestions();
    }
  }

  List<Question> _parseAIResponse(
    String response,
    String subject,
    DifficultyLevel difficulty,
  ) {
    try {
      final data = jsonDecode(response);
      final questions = data['questions'] as List;

      return questions.map((q) {
        QuestionType type;
        switch (q['type']) {
          case 'multipleChoice':
            type = QuestionType.multipleChoice;
            break;
          case 'trueFalse':
            type = QuestionType.trueFalse;
            break;
          case 'enumeration':
            type = QuestionType.enumeration;
            break;
          default:
            type = QuestionType.multipleChoice;
        }

        return Question(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              questions.indexOf(q).toString(),
          text: q['text'],
          type: type,
          options: List<String>.from(q['options'] ?? []),
          correctAnswer: q['correctAnswer'] ?? '',
          correctAnswers: List<String>.from(q['correctAnswers'] ?? []),
          subject: subject,
          difficulty: difficulty,
          explanation: q['explanation'] ?? '',
          createdAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  List<String> _splitContent(String content, {int maxChunkSize = 3000}) {
    if (content.length <= maxChunkSize) {
      return [content];
    }

    List<String> chunks = [];
    List<String> sentences = content.split(RegExp(r'(?<=[.!?])\s+'));
    String currentChunk = '';

    for (String sentence in sentences) {
      if ((currentChunk + sentence).length <= maxChunkSize) {
        currentChunk += (currentChunk.isEmpty ? '' : ' ') + sentence;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
          currentChunk = sentence;
        }
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  /// Generates sample questions for development/testing when AI service is not available
  String _generateSampleQuestions() {
    return jsonEncode({
      "questions": [
        {
          "type": "multipleChoice",
          "text": "What is the main topic of this content?",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswer": "Option A",
          "explanation": "This is a sample explanation.",
        },
        {
          "type": "trueFalse",
          "text": "This statement is true based on the content.",
          "correctAnswer": "True",
          "explanation": "This is a sample true/false explanation.",
        },
      ],
    });
  }

  /// Validates user answer against correct answer
  bool validateAnswer(
    Question question,
    String userAnswer, {
    List<String>? userAnswers,
  }) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return question.correctAnswer.toLowerCase().trim() ==
            userAnswer.toLowerCase().trim();

      case QuestionType.enumeration:
        if (userAnswers == null || userAnswers.isEmpty) return false;

        // Check if user provided all correct answers
        final normalizedCorrect = question.correctAnswers
            .map((a) => a.toLowerCase().trim())
            .toSet();
        final normalizedUser = userAnswers
            .map((a) => a.toLowerCase().trim())
            .toSet();

        return normalizedCorrect.containsAll(normalizedUser) &&
            normalizedUser.containsAll(normalizedCorrect);
    }
  }

  String determineSubject(String content) {
    final subjects = {
      'Math': [
        'equation',
        'algebra',
        'geometry',
        'calculus',
        'mathematics',
        'formula',
        'theorem',
      ],
      'Science': [
        'hypothesis',
        'experiment',
        'molecule',
        'atom',
        'biology',
        'chemistry',
        'physics',
      ],
      'English': [
        'grammar',
        'literature',
        'writing',
        'reading',
        'poetry',
        'novel',
        'essay',
      ],
      'History': [
        'historical',
        'century',
        'war',
        'civilization',
        'ancient',
        'medieval',
        'revolution',
      ],
      'Geography': [
        'continent',
        'country',
        'mountain',
        'river',
        'climate',
        'population',
        'capital',
      ],
    };

    Map<String, int> subjectScores = {};

    for (final entry in subjects.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        score += RegExp(
          keyword,
          caseSensitive: false,
        ).allMatches(content).length;
      }
      subjectScores[entry.key] = score;
    }

    if (subjectScores.values.every((score) => score == 0)) {
      return 'General';
    }

    return subjectScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
