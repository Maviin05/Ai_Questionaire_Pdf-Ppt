import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class PerformanceProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  PerformanceAnalytics? _performanceAnalytics;
  bool _isLoading = false;
  String? _error;

  PerformanceAnalytics? get performanceAnalytics => _performanceAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SubjectPerformance> get strengths =>
      _performanceAnalytics?.strengths ?? [];
  List<SubjectPerformance> get weaknesses =>
      _performanceAnalytics?.weaknesses ?? [];
  double get overallPercentage =>
      _performanceAnalytics?.overallPercentage ?? 0.0;
  int get totalQuizzes => _performanceAnalytics?.totalQuizzes ?? 0;

  /// Load performance analytics for a user
  Future<void> loadPerformanceAnalytics(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _performanceAnalytics = await _databaseService.getPerformanceAnalytics(
        userId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update performance analytics after quiz completion
  Future<void> updatePerformance(String userId, Quiz completedQuiz) async {
    try {
      // Calculate performance metrics for this quiz
      final correctAnswers = completedQuiz.correctAnswers;
      final totalQuestions = completedQuiz.totalQuestions;

      // Update database
      await _databaseService.updatePerformanceAnalytics(
        userId,
        completedQuiz.subject,
        correctAnswers > 0,
        totalQuestions,
      );

      // Reload analytics
      await loadPerformanceAnalytics(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Get performance for a specific subject
  SubjectPerformance? getSubjectPerformance(String subject) {
    return _performanceAnalytics?.getSubjectPerformance(subject);
  }

  /// Get the best performing subject
  SubjectPerformance? getBestSubject() {
    if (_performanceAnalytics == null ||
        _performanceAnalytics!.subjectPerformances.isEmpty) {
      return null;
    }

    return _performanceAnalytics!.subjectPerformances.reduce(
      (a, b) => a.percentage > b.percentage ? a : b,
    );
  }

  /// Get the worst performing subject
  SubjectPerformance? getWorstSubject() {
    if (_performanceAnalytics == null ||
        _performanceAnalytics!.subjectPerformances.isEmpty) {
      return null;
    }

    return _performanceAnalytics!.subjectPerformances.reduce(
      (a, b) => a.percentage < b.percentage ? a : b,
    );
  }

  /// Get subjects that need improvement (below 70%)
  List<SubjectPerformance> getSubjectsNeedingImprovement() {
    return weaknesses;
  }

  /// Get performance trend (simplified - could be enhanced with historical data)
  String getPerformanceTrend() {
    if (_performanceAnalytics == null) return 'No data';

    final overall = _performanceAnalytics!.overallPercentage;

    if (overall >= 85) return 'Excellent';
    if (overall >= 70) return 'Good';
    if (overall >= 50) return 'Fair';
    return 'Needs Improvement';
  }

  /// Get performance color based on percentage
  Color getPerformanceColor(double percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
