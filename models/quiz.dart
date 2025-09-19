import 'question.dart';

enum QuizStatus { notStarted, inProgress, completed }

class UserAnswer {
  final String questionId;
  final String answer;
  final List<String> answers; // For enumeration questions
  final bool isCorrect;
  final DateTime answeredAt;

  UserAnswer({
    required this.questionId,
    required this.answer,
    this.answers = const [],
    required this.isCorrect,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'answer': answer,
      'answers': answers,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.millisecondsSinceEpoch,
    };
  }

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['questionId'],
      answer: json['answer'],
      answers: List<String>.from(json['answers'] ?? []),
      isCorrect: json['isCorrect'],
      answeredAt: DateTime.fromMillisecondsSinceEpoch(json['answeredAt']),
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String sourceFileName;
  final List<Question> questions;
  final List<UserAnswer> userAnswers;
  final QuizStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? score;
  final double? percentage;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.sourceFileName,
    required this.questions,
    this.userAnswers = const [],
    this.status = QuizStatus.notStarted,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.score,
    this.percentage,
  });

  int get totalQuestions => questions.length;
  int get answeredQuestions => userAnswers.length;
  int get correctAnswers =>
      userAnswers.where((answer) => answer.isCorrect).length;

  double get currentPercentage {
    if (answeredQuestions == 0) return 0.0;
    return (correctAnswers / answeredQuestions) * 100;
  }

  bool get isCompleted => status == QuizStatus.completed;

  Duration? get timeTaken {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'sourceFileName': sourceFileName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'userAnswers': userAnswers.map((a) => a.toJson()).toList(),
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startedAt': startedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'score': score,
      'percentage': percentage,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      sourceFileName: json['sourceFileName'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      userAnswers: (json['userAnswers'] as List)
          .map((a) => UserAnswer.fromJson(a))
          .toList(),
      status: QuizStatus.values[json['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      score: json['score'],
      percentage: json['percentage'],
    );
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? subject,
    String? sourceFileName,
    List<Question>? questions,
    List<UserAnswer>? userAnswers,
    QuizStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? score,
    double? percentage,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
    );
  }
}
