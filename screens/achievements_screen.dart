import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/models.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements'), centerTitle: true),
      body: Consumer<AchievementProvider>(
        builder: (context, achievementProvider, child) {
          if (achievementProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Badges', icon: FaIcon(FontAwesomeIcons.award)),
                    Tab(text: 'Medals', icon: FaIcon(FontAwesomeIcons.medal)),
                    Tab(text: 'Ribbons', icon: FaIcon(FontAwesomeIcons.ribbon)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AchievementGrid(
                        achievements: achievementProvider.badges,
                      ),
                      _AchievementGrid(
                        achievements: achievementProvider.medals,
                      ),
                      _AchievementGrid(
                        achievements: achievementProvider.ribbons,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No achievements yet'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getAchievementIcon(achievement.type),
              size: 48,
              color: achievement.isUnlocked
                  ? _getAchievementColor(achievement.type)
                  : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked ? null : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: achievement.isUnlocked ? Colors.grey[600] : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Locked',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.badge:
        return FontAwesomeIcons.award;
      case AchievementType.medal:
        return FontAwesomeIcons.medal;
      case AchievementType.ribbon:
        return FontAwesomeIcons.ribbon;
    }
  }

  Color _getAchievementColor(AchievementType type) {
    switch (type) {
      case AchievementType.badge:
        return Colors.blue;
      case AchievementType.medal:
        return Colors.amber;
      case AchievementType.ribbon:
        return Colors.purple;
    }
  }
}
