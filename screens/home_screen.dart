import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/models.dart';
import '../providers/quiz_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/performance_provider.dart';
import 'pdf_upload_screen.dart';
import 'quiz_list_screen.dart';
import 'achievements_screen.dart';
import 'performance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const QuizListScreen(),
    const AchievementsScreen(),
    const PerformanceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    const userId = 'user_1';

    Future.microtask(() {
      context.read<QuizProvider>().loadQuizzes();
      context.read<AchievementProvider>().loadAchievements(userId);
      context.read<PerformanceProvider>().loadPerformanceAnalytics(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.trophy),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Performance',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Questionnaire'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to AI Questionnaire',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload PDFs and let AI generate personalized questions for you!',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DocumentUploadScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Document & Create Quiz'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Consumer3<QuizProvider, AchievementProvider, PerformanceProvider>(
              builder:
                  (
                    context,
                    quizProvider,
                    achievementProvider,
                    performanceProvider,
                    child,
                  ) {
                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.quiz,
                            title: 'Total Quizzes',
                            value: '${quizProvider.quizzes.length}',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            icon: FontAwesomeIcons.trophy,
                            title: 'Achievements',
                            value:
                                '${achievementProvider.achievements.where((a) => a.isUnlocked).length}',
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    );
                  },
            ),

            const SizedBox(height: 16),

            Consumer<PerformanceProvider>(
              builder: (context, performanceProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        title: 'Overall Score',
                        value:
                            '${performanceProvider.overallPercentage.toInt()}%',
                        color: performanceProvider.getPerformanceColor(
                          performanceProvider.overallPercentage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.schedule,
                        title: 'Study Streak',
                        value: '0 days', // Placeholder
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Achievements
            Consumer<AchievementProvider>(
              builder: (context, achievementProvider, child) {
                if (achievementProvider.recentlyUnlocked.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...achievementProvider.recentlyUnlocked
                        .take(3)
                        .map(
                          (achievement) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: Icon(
                                  _getAchievementIcon(achievement.type),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(achievement.name),
                              subtitle: Text(achievement.description),
                              trailing: Text(
                                'Just now',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                  ],
                );
              },
            ),
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
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
