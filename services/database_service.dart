import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'ai_questionnaire.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _quizzesTable = 'quizzes';
  static const String _questionsTable = 'questions';
  static const String _userAnswersTable = 'user_answers';
  static const String _achievementsTable = 'achievements';
  static const String _userAchievementsTable = 'user_achievements';
  static const String _performanceTable = 'performance_analytics';

  /// Gets database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatar_path TEXT,
        created_at INTEGER NOT NULL,
        last_active_at INTEGER NOT NULL,
        preferences TEXT,
        favorite_subjects TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_quizzesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        source_file_name TEXT NOT NULL,
        status INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        started_at INTEGER,
        completed_at INTEGER,
        score INTEGER,
        percentage REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_questionsTable (
        id TEXT PRIMARY KEY,
        quiz_id TEXT NOT NULL,
        text TEXT NOT NULL,
        type INTEGER NOT NULL,
        options TEXT,
        correct_answer TEXT NOT NULL,
        correct_answers TEXT,
        subject TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        explanation TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (quiz_id) REFERENCES $_quizzesTable (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_userAnswersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        answer TEXT NOT NULL,
        answers TEXT,
        is_correct INTEGER NOT NULL,
        answered_at INTEGER NOT NULL,
        FOREIGN KEY (quiz_id) REFERENCES $_quizzesTable (id),
        FOREIGN KEY (question_id) REFERENCES $_questionsTable (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_achievementsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type INTEGER NOT NULL,
        category INTEGER NOT NULL,
        icon_path TEXT NOT NULL,
        subject TEXT,
        criteria TEXT NOT NULL
      )
    ''');

    // User achievements table
    await db.execute('''
      CREATE TABLE $_userAchievementsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        achievement_id TEXT NOT NULL,
        unlocked_at INTEGER NOT NULL,
        progress TEXT,
        FOREIGN KEY (user_id) REFERENCES $_usersTable (id),
        FOREIGN KEY (achievement_id) REFERENCES $_achievementsTable (id)
      )
    ''');

    // Performance analytics table
    await db.execute('''
      CREATE TABLE $_performanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        subject TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        percentage REAL NOT NULL,
        quizzes_taken INTEGER NOT NULL,
        last_activity INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_usersTable (id)
      )
    ''');

    // Insert default achievements
    await _insertDefaultAchievements(db);
  }

  /// Inserts default achievements into the database
  Future<void> _insertDefaultAchievements(Database db) async {
    final achievements = [
      // Badges - Progress and Habit Builders
      Achievement(
        id: 'badge_first_quiz',
        name: 'First Steps',
        description: 'Completed your first quiz',
        type: AchievementType.badge,
        category: AchievementCategory.progress,
        iconPath: 'assets/badges/first_quiz.png',
        criteria: {'quizzes_completed': 1},
      ),
      Achievement(
        id: 'badge_study_streak_5',
        name: 'Study Streak',
        description: 'Completed 5 study sessions this week',
        type: AchievementType.badge,
        category: AchievementCategory.consistency,
        iconPath: 'assets/badges/study_streak.png',
        criteria: {'weekly_sessions': 5},
      ),
      Achievement(
        id: 'badge_focused_learner',
        name: 'Focused Learner',
        description: 'Focused for 30 minutes without distraction',
        type: AchievementType.badge,
        category: AchievementCategory.consistency,
        iconPath: 'assets/badges/focused.png',
        criteria: {'focus_time_minutes': 30},
      ),

      // Medals - Personal Milestones
      Achievement(
        id: 'medal_first_month',
        name: 'Monthly Scholar',
        description: 'First full month of studying',
        type: AchievementType.medal,
        category: AchievementCategory.milestone,
        iconPath: 'assets/medals/first_month.png',
        criteria: {'active_days_in_month': 20},
      ),
      Achievement(
        id: 'medal_perfect_score',
        name: 'Perfect Scholar',
        description: 'Achieved 100% on a quiz',
        type: AchievementType.medal,
        category: AchievementCategory.milestone,
        iconPath: 'assets/medals/perfect_score.png',
        criteria: {'perfect_quiz': true},
      ),

      // Ribbons - Subject-Specific Recognition
      Achievement(
        id: 'ribbon_english_master',
        name: 'English Master',
        description: 'Best in English',
        type: AchievementType.ribbon,
        category: AchievementCategory.subject,
        iconPath: 'assets/ribbons/english.png',
        subject: 'English',
        criteria: {'subject_mastery': 'English', 'min_percentage': 85.0},
      ),
      Achievement(
        id: 'ribbon_math_master',
        name: 'Math Master',
        description: 'Best in Math',
        type: AchievementType.ribbon,
        category: AchievementCategory.subject,
        iconPath: 'assets/ribbons/math.png',
        subject: 'Math',
        criteria: {'subject_mastery': 'Math', 'min_percentage': 85.0},
      ),
      Achievement(
        id: 'ribbon_science_master',
        name: 'Science Master',
        description: 'Best in Science',
        type: AchievementType.ribbon,
        category: AchievementCategory.subject,
        iconPath: 'assets/ribbons/science.png',
        subject: 'Science',
        criteria: {'subject_mastery': 'Science', 'min_percentage': 85.0},
      ),
    ];

    for (final achievement in achievements) {
      await db.insert(_achievementsTable, {
        'id': achievement.id,
        'name': achievement.name,
        'description': achievement.description,
        'type': achievement.type.index,
        'category': achievement.category.index,
        'icon_path': achievement.iconPath,
        'subject': achievement.subject,
        'criteria': jsonEncode(achievement.criteria),
      });
    }
  }

  // Quiz operations
  Future<String> saveQuiz(Quiz quiz) async {
    final db = await database;

    await db.insert(_quizzesTable, {
      'id': quiz.id,
      'title': quiz.title,
      'subject': quiz.subject,
      'source_file_name': quiz.sourceFileName,
      'status': quiz.status.index,
      'created_at': quiz.createdAt.millisecondsSinceEpoch,
      'started_at': quiz.startedAt?.millisecondsSinceEpoch,
      'completed_at': quiz.completedAt?.millisecondsSinceEpoch,
      'score': quiz.score,
      'percentage': quiz.percentage,
    });

    // Save questions
    for (final question in quiz.questions) {
      await db.insert(_questionsTable, {
        'id': question.id,
        'quiz_id': quiz.id,
        'text': question.text,
        'type': question.type.index,
        'options': jsonEncode(question.options),
        'correct_answer': question.correctAnswer,
        'correct_answers': jsonEncode(question.correctAnswers),
        'subject': question.subject,
        'difficulty': question.difficulty.index,
        'explanation': question.explanation,
        'created_at': question.createdAt.millisecondsSinceEpoch,
      });
    }

    return quiz.id;
  }

  Future<void> updateQuiz(Quiz quiz) async {
    final db = await database;

    await db.update(
      _quizzesTable,
      {
        'title': quiz.title,
        'subject': quiz.subject,
        'source_file_name': quiz.sourceFileName,
        'status': quiz.status.index,
        'started_at': quiz.startedAt?.millisecondsSinceEpoch,
        'completed_at': quiz.completedAt?.millisecondsSinceEpoch,
        'score': quiz.score,
        'percentage': quiz.percentage,
      },
      where: 'id = ?',
      whereArgs: [quiz.id],
    );
  }

  Future<Quiz?> getQuiz(String quizId) async {
    final db = await database;

    final quizMaps = await db.query(
      _quizzesTable,
      where: 'id = ?',
      whereArgs: [quizId],
    );

    if (quizMaps.isEmpty) return null;

    final quizData = quizMaps.first;

    // Get questions
    final questionMaps = await db.query(
      _questionsTable,
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );

    final questions = questionMaps
        .map(
          (q) => Question(
            id: q['id'] as String,
            text: q['text'] as String,
            type: QuestionType.values[q['type'] as int],
            options: List<String>.from(
              jsonDecode(q['options'] as String? ?? '[]'),
            ),
            correctAnswer: q['correct_answer'] as String,
            correctAnswers: List<String>.from(
              jsonDecode(q['correct_answers'] as String? ?? '[]'),
            ),
            subject: q['subject'] as String,
            difficulty: DifficultyLevel.values[q['difficulty'] as int],
            explanation: q['explanation'] as String? ?? '',
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              q['created_at'] as int,
            ),
          ),
        )
        .toList();

    // Get user answers
    final answerMaps = await db.query(
      _userAnswersTable,
      where: 'quiz_id = ?',
      whereArgs: [quizId],
    );

    final userAnswers = answerMaps
        .map(
          (a) => UserAnswer(
            questionId: a['question_id'] as String,
            answer: a['answer'] as String,
            answers: List<String>.from(
              jsonDecode(a['answers'] as String? ?? '[]'),
            ),
            isCorrect: (a['is_correct'] as int) == 1,
            answeredAt: DateTime.fromMillisecondsSinceEpoch(
              a['answered_at'] as int,
            ),
          ),
        )
        .toList();

    return Quiz(
      id: quizData['id'] as String,
      title: quizData['title'] as String,
      subject: quizData['subject'] as String,
      sourceFileName: quizData['source_file_name'] as String,
      questions: questions,
      userAnswers: userAnswers,
      status: QuizStatus.values[quizData['status'] as int],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        quizData['created_at'] as int,
      ),
      startedAt: quizData['started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(quizData['started_at'] as int)
          : null,
      completedAt: quizData['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(quizData['completed_at'] as int)
          : null,
      score: quizData['score'] as int?,
      percentage: quizData['percentage'] as double?,
    );
  }

  Future<List<Quiz>> getAllQuizzes() async {
    final db = await database;
    final quizMaps = await db.query(_quizzesTable, orderBy: 'created_at DESC');

    List<Quiz> quizzes = [];
    for (final quizData in quizMaps) {
      final quiz = await getQuiz(quizData['id'] as String);
      if (quiz != null) quizzes.add(quiz);
    }

    return quizzes;
  }

  Future<void> saveUserAnswer(String quizId, UserAnswer answer) async {
    final db = await database;

    await db.insert(_userAnswersTable, {
      'quiz_id': quizId,
      'question_id': answer.questionId,
      'answer': answer.answer,
      'answers': jsonEncode(answer.answers),
      'is_correct': answer.isCorrect ? 1 : 0,
      'answered_at': answer.answeredAt.millisecondsSinceEpoch,
    });
  }

  // Performance Analytics
  Future<void> updatePerformanceAnalytics(
    String userId,
    String subject,
    bool isCorrect,
    int totalQuestions,
  ) async {
    final db = await database;

    final existing = await db.query(
      _performanceTable,
      where: 'user_id = ? AND subject = ?',
      whereArgs: [userId, subject],
    );

    if (existing.isEmpty) {
      await db.insert(_performanceTable, {
        'user_id': userId,
        'subject': subject,
        'total_questions': totalQuestions,
        'correct_answers': isCorrect ? 1 : 0,
        'percentage': isCorrect ? 100.0 / totalQuestions : 0.0,
        'quizzes_taken': 1,
        'last_activity': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      final current = existing.first;
      final newTotalQuestions =
          (current['total_questions'] as int) + totalQuestions;
      final newCorrectAnswers =
          (current['correct_answers'] as int) + (isCorrect ? 1 : 0);
      final newPercentage = (newCorrectAnswers / newTotalQuestions) * 100;

      await db.update(
        _performanceTable,
        {
          'total_questions': newTotalQuestions,
          'correct_answers': newCorrectAnswers,
          'percentage': newPercentage,
          'quizzes_taken': (current['quizzes_taken'] as int) + 1,
          'last_activity': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'user_id = ? AND subject = ?',
        whereArgs: [userId, subject],
      );
    }
  }

  Future<PerformanceAnalytics?> getPerformanceAnalytics(String userId) async {
    final db = await database;

    final performanceMaps = await db.query(
      _performanceTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (performanceMaps.isEmpty) return null;

    final subjectPerformances = performanceMaps
        .map(
          (p) => SubjectPerformance(
            subject: p['subject'] as String,
            totalQuestions: p['total_questions'] as int,
            correctAnswers: p['correct_answers'] as int,
            percentage: p['percentage'] as double,
            quizzesTaken: p['quizzes_taken'] as int,
            lastActivity: DateTime.fromMillisecondsSinceEpoch(
              p['last_activity'] as int,
            ),
          ),
        )
        .toList();

    final totalQuestions = subjectPerformances.fold(
      0,
      (sum, sp) => sum + sp.totalQuestions,
    );
    final totalCorrect = subjectPerformances.fold(
      0,
      (sum, sp) => sum + sp.correctAnswers,
    );
    final totalQuizzes = subjectPerformances.fold(
      0,
      (sum, sp) => sum + sp.quizzesTaken,
    );

    return PerformanceAnalytics(
      userId: userId,
      subjectPerformances: subjectPerformances,
      totalQuizzes: totalQuizzes,
      totalQuestions: totalQuestions,
      totalCorrectAnswers: totalCorrect,
      overallPercentage: totalQuestions > 0
          ? (totalCorrect / totalQuestions) * 100
          : 0.0,
      totalStudyTime: const Duration(hours: 0), // TODO: Implement time tracking
      lastUpdated: DateTime.now(),
    );
  }

  // Achievement operations
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final achievementMaps = await db.query(_achievementsTable);

    return achievementMaps
        .map(
          (a) => Achievement(
            id: a['id'] as String,
            name: a['name'] as String,
            description: a['description'] as String,
            type: AchievementType.values[a['type'] as int],
            category: AchievementCategory.values[a['category'] as int],
            iconPath: a['icon_path'] as String,
            subject: a['subject'] as String? ?? '',
            criteria: Map<String, dynamic>.from(
              jsonDecode(a['criteria'] as String),
            ),
          ),
        )
        .toList();
  }

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final db = await database;
    final userAchievementMaps = await db.query(
      _userAchievementsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return userAchievementMaps
        .map(
          (ua) => UserAchievement(
            userId: ua['user_id'] as String,
            achievementId: ua['achievement_id'] as String,
            unlockedAt: DateTime.fromMillisecondsSinceEpoch(
              ua['unlocked_at'] as int,
            ),
            progress: Map<String, dynamic>.from(
              jsonDecode(ua['progress'] as String? ?? '{}'),
            ),
          ),
        )
        .toList();
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    final db = await database;

    // Check if already unlocked
    final existing = await db.query(
      _userAchievementsTable,
      where: 'user_id = ? AND achievement_id = ?',
      whereArgs: [userId, achievementId],
    );

    if (existing.isEmpty) {
      await db.insert(_userAchievementsTable, {
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().millisecondsSinceEpoch,
        'progress': '{}',
      });
    }
  }

  /// Closes the database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
