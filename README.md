# AI Questionnaire App

A comprehensive Flutter application that generates intelligent quizzes from documents (PDF and PowerPoint) using AI, with performance tracking and achievement system.

## � Features

### 📄 Document Processing
- Upload PDF documents (.pdf)
- Upload PowerPoint presentations (.ppt, .pptx)
- Extract and preprocess text content from documents
- Automatic subject detection and content analysis
- Support for various document formats

### 🤖 AI-Powered Question Generation
- **Multiple Choice**: 4 options with one correct answer
- **True/False**: Binary choice questions
- **Enumeration**: List-based questions requiring multiple answers
- **Configurable Difficulty**: Easy, Medium, Hard levels
- **Smart Content Analysis**: AI analyzes document content for relevant questions
- **Batch Processing**: Handles large documents by chunking content

### 📊 Performance Analytics
- Subject-specific performance tracking
- Overall score and progress monitoring
- Strengths and weaknesses identification
- Detailed quiz statistics and history
- Performance trends over time

### 🏆 Achievement System
**Three Types of Rewards:**

| Type | Purpose | Examples |
|------|---------|----------|
| **🏅 Badges** | Progress & Habits | "5 Study Sessions This Week", "30 Min Focused Study" |
| **🥇 Medals** | Personal Milestones | "First Full Month", "Perfect Score", "Quiz Master" |
| **🎗️ Ribbons** | Subject Mastery | "English Master", "Math Expert", "Science Pro" |

### 🎯 Quiz Customization
- Choose number of questions (5-50)
- Select specific question types
- Set difficulty level
- Custom quiz titles and subjects
- Flexible quiz configuration

### 💾 Data Persistence
- SQLite database for offline functionality
- Quiz history and progress tracking
- Achievement progress persistence
- Performance analytics storage
- Local file management

## 🛠️ Technical Architecture

### 📱 Tech Stack
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider pattern
- **AI Integration**: HTTP API calls (Groq/OpenAI compatible)
- **Document Processing**: Syncfusion PDF, Archive/XML parsing
- **UI**: Material Design 3 with custom theming

### 🏗️ Project Structure
```
lib/
├── models/               # Data models
│   ├── question.dart     # Question model with types and validation
│   ├── quiz.dart         # Quiz structure and metadata
│   ├── achievement.dart  # Achievement system models
│   ├── user.dart         # User profile and preferences
│   └── performance_analytics.dart
├── services/             # Business logic services
│   ├── ai_service.dart   # AI question generation
│   ├── database_service.dart  # SQLite operations
│   └── document_service.dart  # PDF/PPT processing
├── providers/            # State management
│   ├── quiz_provider.dart
│   ├── achievement_provider.dart
│   └── performance_provider.dart
├── screens/              # UI screens
│   ├── home_screen.dart
│   ├── quiz_list_screen.dart
│   ├── pdf_upload_screen.dart
│   ├── achievements_screen.dart
│   └── performance_screen.dart
├── widgets/              # Reusable UI components
└── main.dart            # App entry point
```

### 🔧 Key Models

**Question Model:**
```dart
class Question {
  final String id;
  final String text;
  final QuestionType type;  // multipleChoice, trueFalse, enumeration
  final List<String> options;
  final String correctAnswer;
  final List<String> correctAnswers;  // For enumeration
  final String subject;
  final DifficultyLevel difficulty;
  final String explanation;
  final DateTime createdAt;
}
```

**Quiz Model:**
```dart
class Quiz {
  final String id;
  final String title;
  final String subject;
  final List<Question> questions;
  final DateTime createdAt;
  final QuizStatus status;
  final Map<String, String> userAnswers;
  final double? score;
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- AI API key (Groq, OpenAI, or compatible service)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ai_questionaire.git
   cd ai_questionaire
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env and add your API key
   GROQ_API_KEY=your_actual_api_key_here
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### 🔑 API Configuration

The app uses environment variables for secure API key management:

1. Create a `.env` file in the project root
2. Add your API key:
   ```
   GROQ_API_KEY=your_groq_api_key_here
   ```
3. The app automatically loads this configuration at startup

**Supported AI Providers:**
- Groq (default)
- OpenAI (modify base URL in `ai_service.dart`)
- Any OpenAI-compatible API

## 📱 Usage Guide

### Creating a Quiz
1. **Upload Document**: Tap "Upload PDF & Create Quiz" from the home screen
2. **Select File**: Choose a PDF or PowerPoint file
3. **Configure Quiz**:
   - Enter quiz title
   - Set number of questions (5-50)
   - Choose difficulty level
   - Select question types
4. **Generate**: AI processes the document and creates questions
5. **Review**: Quiz is saved and ready to take

### Taking a Quiz
1. Navigate to "Quizzes" tab
2. Select a quiz from your library
3. Answer questions based on type:
   - **Multiple Choice**: Select one option
   - **True/False**: Choose True or False
   - **Enumeration**: List multiple answers (comma-separated)
4. Submit and view results with explanations

### Tracking Performance
1. Go to "Performance" tab
2. View overall statistics and trends
3. Analyze strengths and weaknesses by subject
4. Monitor progress over time

### Earning Achievements
1. Complete quizzes and study sessions
2. Check "Achievements" tab for progress
3. View recently earned badges, medals, and ribbons
4. Track unlock criteria for upcoming achievements

## 🏗️ Development

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  
  # State Management
  provider: ^6.1.2
  
  # Document Processing
  file_picker: ^8.0.7
  syncfusion_flutter_pdf: ^26.2.14
  archive: ^3.6.1
  xml: ^6.5.0
  
  # Database & Storage
  sqflite: ^2.3.3+1
  shared_preferences: ^2.3.2
  path: ^1.9.0
  
  # Networking
  http: ^1.2.2
  dio: ^5.6.0
  
  # Environment Variables
  flutter_dotenv: ^5.1.0
  
  # UI & Animation
  animations: ^2.0.11
  lottie: ^3.1.2
  flutter_staggered_animations: ^1.1.1
  font_awesome_flutter: ^10.7.0
  google_fonts: ^6.2.1
```

### Environment Setup
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

### Code Structure Guidelines
- **Models**: Pure data classes with serialization
- **Services**: Business logic and external API integration
- **Providers**: State management with ChangeNotifier
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Test files are located in the `test/` directory and cover:
- Document service functionality
- Widget testing
- Model validation
- Database operations

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Development Guidelines
- Follow Dart/Flutter style guidelines
- Add tests for new features
- Update documentation for API changes
- Use conventional commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

### Common Issues

**PDF Upload Fails:**
- Verify file format (PDF/PPT/PPTX only)
- Check file size (< 10MB recommended)
- Ensure sufficient device storage

**AI Generation Fails:**
- Verify API key in `.env` file
- Check internet connectivity
- Monitor API rate limits

**App Performance:**
- Clear app cache: Settings > Storage > Clear Cache
- Restart the application
- Check available device memory

**Database Issues:**
- App will recreate database on next launch if corrupted
- User data is automatically backed up locally

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/your-username/ai_questionaire/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/your-username/ai_questionaire/discussions)
- 📧 **Email**: support@yourapp.com

## 🗺️ Roadmap

### v2.0 (Planned)
- [ ] Cloud synchronization with Firebase
- [ ] Multi-user support and sharing
- [ ] Advanced analytics dashboard
- [ ] Export functionality (PDF reports)
- [ ] Offline AI model support

### v2.1 (Future)
- [ ] Voice-to-text for answers
- [ ] OCR for image-based PDFs
- [ ] Social features and leaderboards
- [ ] Custom achievement creation
- [ ] Integration with learning management systems

---

**Built with ❤️ using Flutter & AI Technology**

*Last updated: September 2025*
