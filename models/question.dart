enum QuestionType { multipleChoice, trueFalse, enumeration }

enum DifficultyLevel { easy, medium, hard }

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options; // For multiple choice and enumeration
  final String correctAnswer;
  final List<String> correctAnswers; // For enumeration questions
  final String subject;
  final DifficultyLevel difficulty;
  final String explanation;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.correctAnswers = const [],
    required this.subject,
    required this.difficulty,
    this.explanation = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.index,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'subject': subject,
      'difficulty': difficulty.index,
      'explanation': explanation,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: QuestionType.values[json['type']],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'],
      correctAnswers: List<String>.from(json['correctAnswers'] ?? []),
      subject: json['subject'],
      difficulty: DifficultyLevel.values[json['difficulty']],
      explanation: json['explanation'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    String? correctAnswer,
    List<String>? correctAnswers,
    String? subject,
    DifficultyLevel? difficulty,
    String? explanation,
    DateTime? createdAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
