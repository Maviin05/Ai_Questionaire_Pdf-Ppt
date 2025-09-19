import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService();

  List<Achievement> _achievements = [];
  Map<AchievementType, List<Achievement>> _achievementsByType = {};
  List<Achievement> _recentlyUnlocked = [];
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _achievements;
  Map<AchievementType, List<Achievement>> get achievementsByType =>
      _achievementsByType;
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Achievement> get badges =>
      _achievementsByType[AchievementType.badge] ?? [];
  List<Achievement> get medals =>
      _achievementsByType[AchievementType.medal] ?? [];
  List<Achievement> get ribbons =>
      _achievementsByType[AchievementType.ribbon] ?? [];

  /// Load all achievements for a user
  Future<void> loadAchievements(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _achievements = await _achievementService.getUserAchievementsWithStatus(
        userId,
      );
      _achievementsByType = await _achievementService.getAchievementsByType(
        userId,
      );
      _recentlyUnlocked = await _achievementService.getRecentlyUnlocked(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check for new achievements after quiz completion
  Future<List<Achievement>> checkAchievements(
    String userId,
    Quiz completedQuiz,
    PerformanceAnalytics? performance,
  ) async {
    try {
      final newAchievements = await _achievementService
          .checkAndUnlockAchievements(userId, completedQuiz, performance);

      if (newAchievements.isNotEmpty) {
        // Update local lists
        for (final achievement in newAchievements) {
          final index = _achievements.indexWhere((a) => a.id == achievement.id);
          if (index != -1) {
            _achievements[index] = achievement;
          }
        }

        // Update grouped achievements
        _achievementsByType = await _achievementService.getAchievementsByType(
          userId,
        );

        // Add to recently unlocked
        _recentlyUnlocked.addAll(newAchievements);

        notifyListeners();
      }

      return newAchievements;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get achievement progress (0.0 to 1.0)
  Future<double> getAchievementProgress(
    String userId,
    String achievementId,
  ) async {
    try {
      return await _achievementService.getAchievementProgress(
        userId,
        achievementId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  /// Get unlocked achievements count by type
  int getUnlockedCount(AchievementType type) {
    final typeAchievements = _achievementsByType[type] ?? [];
    return typeAchievements.where((a) => a.isUnlocked).length;
  }

  /// Get total achievements count by type
  int getTotalCount(AchievementType type) {
    return _achievementsByType[type]?.length ?? 0;
  }

  /// Clear recently unlocked achievements (after showing notification)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
