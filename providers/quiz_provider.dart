import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class QuizProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final DocumentService _documentService = DocumentService();
  final AIService _aiService = AIService();

  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all quizzes from database
  Future<void> loadQuizzes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _quizzes = await _databaseService.getAllQuizzes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create quiz from document file (PDF or PowerPoint)
  Future<Quiz?> createQuizFromDocument({
    required File documentFile,
    required String title,
    required int numberOfQuestions,
    required List<QuestionType> questionTypes,
    required DifficultyLevel difficulty,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if file format is supported
      if (!_documentService.isSupportedDocument(documentFile.path)) {
        throw Exception(
          'Unsupported file format. Supported formats: PDF, PPT, PPTX',
        );
      }

      // Extract text from document
      final extractedText = await _documentService.extractTextFromDocument(
        documentFile,
      );
      final cleanText = _documentService.preprocessText(extractedText);

      // Determine subject
      final subject = _aiService.determineSubject(cleanText);

      // Generate questions
      final questions = await _aiService.generateQuestions(
        content: cleanText,
        subject: subject,
        numberOfQuestions: numberOfQuestions,
        questionTypes: questionTypes,
        difficulty: difficulty,
      );

      // Create quiz
      final quiz = Quiz(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        subject: subject,
        sourceFileName: documentFile.path.split('/').last,
        questions: questions,
        createdAt: DateTime.now(),
      );

      // Save to database
      await _databaseService.saveQuiz(quiz);

      // Add to local list
      _quizzes.insert(0, quiz);

      _isLoading = false;
      notifyListeners();

      return quiz;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Create quiz from PDF file (deprecated - use createQuizFromDocument)
  @Deprecated('Use createQuizFromDocument instead')
  Future<Quiz?> createQuizFromPdf({
    required File pdfFile,
    required String title,
    required int numberOfQuestions,
    required List<QuestionType> questionTypes,
    required DifficultyLevel difficulty,
  }) async {
    return createQuizFromDocument(
      documentFile: pdfFile,
      title: title,
      numberOfQuestions: numberOfQuestions,
      questionTypes: questionTypes,
      difficulty: difficulty,
    );
  }

  /// Start a quiz
  Future<void> startQuiz(String quizId) async {
    try {
      final quiz = await _databaseService.getQuiz(quizId);
      if (quiz != null) {
        _currentQuiz = quiz.copyWith(
          status: QuizStatus.inProgress,
          startedAt: DateTime.now(),
        );
        await _databaseService.updateQuiz(_currentQuiz!);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Submit answer for current question
  Future<void> submitAnswer({
    required String questionId,
    required String answer,
    List<String>? answers,
  }) async {
    if (_currentQuiz == null) return;

    try {
      final question = _currentQuiz!.questions.firstWhere(
        (q) => q.id == questionId,
      );
      final isCorrect = _aiService.validateAnswer(
        question,
        answer,
        userAnswers: answers,
      );

      final userAnswer = UserAnswer(
        questionId: questionId,
        answer: answer,
        answers: answers ?? [],
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      );

      // Save answer to database
      await _databaseService.saveUserAnswer(_currentQuiz!.id, userAnswer);

      // Update current quiz
      final updatedAnswers = List<UserAnswer>.from(_currentQuiz!.userAnswers)
        ..add(userAnswer);
      _currentQuiz = _currentQuiz!.copyWith(userAnswers: updatedAnswers);

      // Check if quiz is completed
      if (_currentQuiz!.userAnswers.length == _currentQuiz!.questions.length) {
        await _completeQuiz();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Complete the current quiz
  Future<void> _completeQuiz() async {
    if (_currentQuiz == null) return;

    final correctAnswers = _currentQuiz!.correctAnswers;
    final totalQuestions = _currentQuiz!.totalQuestions;
    final percentage = (correctAnswers / totalQuestions) * 100;

    _currentQuiz = _currentQuiz!.copyWith(
      status: QuizStatus.completed,
      completedAt: DateTime.now(),
      score: correctAnswers,
      percentage: percentage,
    );

    await _databaseService.updateQuiz(_currentQuiz!);

    // Update quiz in the list
    final index = _quizzes.indexWhere((q) => q.id == _currentQuiz!.id);
    if (index != -1) {
      _quizzes[index] = _currentQuiz!;
    }
  }

  /// Get quiz by ID
  Future<Quiz?> getQuiz(String quizId) async {
    try {
      return await _databaseService.getQuiz(quizId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear current quiz
  void clearCurrentQuiz() {
    _currentQuiz = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
