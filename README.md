# AI Questionnaire App

A comprehensive Flutter application that generates intelligent quizzes from documents (PDF and PowerPoint) using AI, with performance tracking and achievement system.

> **🎉 SUCCESS: This Flutter app has been successfully converted to React Native!**
> 
> **Conversion Status:** ✅ **COMPLETED** (4/5 major tasks done)
> - ✅ React Native Expo project setup with TypeScript
> - ✅ Firebase Firestore integration (replacing SQLite)
> - ✅ Complete data models converted from Dart to TypeScript
> - ✅ All core services implemented (AI, Database, Document processing)
> - 🚧 UI screens conversion in progress
>
> **New Features Added in React Native Version:**
> - 🔥 Firebase Firestore for real-time cloud sync
> - 📱 Expo Go for instant testing on any device
> - 🌐 Enhanced cross-platform support
> - 💾 Cloud-based data persistence

## Features

### 📄 Document Processing
- Upload PDF documents (.pdf)
- Upload PowerPoint presentations (.ppt, .pptx)
- Extract and preprocess text content from slides and speaker notes
- Support for various document formats
- Automatic subject detection

### 🤖 AI-Powered Question Generation
- Multiple choice questions (4 options)
- True/False questions
- Enumeration questions (list-based answers)
- Configurable difficulty levels (Easy, Medium, Hard)
- Intelligent content analysis for relevant questions

### 📊 Performance Analytics
**Strengths & Weaknesses Tracking:**
```
STRENGTHS           |  WEAKNESSES
___________________|__________________
English Subject    |  Math Subject
                   |  Science Subject
                   |
```

- Subject-specific performance analysis
- Overall score tracking
- Progress monitoring over time
- Detailed quiz statistics

### 🏆 Achievement System
**Three Types of Rewards:**

| Reward Type | Purpose                    | Example Use                              |
|-------------|---------------------------|------------------------------------------|
| **Badges**  | Progress and Habit Builder | "Completed 5 Study Sessions This Week"  |
|             | Encourage consistency     | "Focused for 30 Minutes Without Distraction" |
| **Medals**  | Personal Milestone        | "First Full Month of Studying"          |
|             |                           | "Mastered All Vocabulary in Unit 1"     |
| **Ribbons** | Subject-Specific Recognition | "Best in English"                     |
|             |                           | "Best in Science", "Best in Math"       |

### 🎯 Quiz Customization
- Choose number of questions (5-50)
- Select question types
- Set difficulty level
- Custom quiz titles

### 💾 Local Storage
- SQLite database for offline functionality
- Quiz history and progress tracking
- Achievement progress persistence
- Performance analytics storage

## Technical Architecture

### Models
- **Question**: Represents individual quiz questions with metadata
- **Quiz**: Complete quiz structure with questions and user answers
- **Achievement**: Badge/medal/ribbon system with unlock criteria
- **PerformanceAnalytics**: Subject-wise performance tracking
- **User**: User profile and preferences

### Services
- **DocumentService**: PDF and PowerPoint text extraction and preprocessing
- **PdfService**: Legacy PDF-only service (deprecated)
- **AIService**: Question generation and answer validation
- **DatabaseService**: Local data persistence
- **AchievementService**: Achievement logic and progress tracking

### Providers (State Management)
- **QuizProvider**: Quiz creation and management
- **AchievementProvider**: Achievement tracking
- **PerformanceProvider**: Analytics and progress monitoring

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.2+)
- Dart SDK
- Android Studio / VS Code
- API key for AI service (OpenAI, Groq, etc.)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ai_questionaire
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure AI Service:**
   - Open `lib/services/ai_service.dart`
   - Replace `YOUR_API_KEY_HERE` with your actual API key
   - Update the `_baseUrl` if using a different AI service

4. **Run the app:**
   ```bash
   flutter run
   ```

### Configuration Options

#### AI Service Configuration
The app supports multiple AI providers. Update the following in `ai_service.dart`:

```dart
// For OpenAI
static const String _baseUrl = 'https://api.openai.com/v1';
static const String _apiKey = 'your-openai-api-key';

// For other providers, update accordingly
```

#### Database Configuration
The app uses SQLite for local storage. No additional configuration required.

## Usage Guide

### Creating a Quiz
1. Navigate to the Dashboard
2. Tap "Upload PDF & Create Quiz"
3. Select a PDF file from your device
4. Configure quiz settings:
   - Enter quiz title
   - Choose number of questions
   - Select difficulty level
   - Pick question types
5. Tap "Generate Quiz"

### Taking a Quiz
1. Go to "Quizzes" tab
2. Select a quiz from the list
3. Answer questions according to their type:
   - **Multiple Choice**: Select one option
   - **True/False**: Choose True or False
   - **Enumeration**: List multiple answers
4. View results and explanations

### Viewing Performance
1. Navigate to "Performance" tab
2. View overall statistics
3. Check strengths and weaknesses by subject
4. Track progress over time

### Checking Achievements
1. Go to "Achievements" tab
2. Browse badges, medals, and ribbons
3. View unlock progress
4. See recently earned achievements

## Achievement Details

### Badges (Progress & Consistency)
- **First Steps**: Complete your first quiz
- **Study Streak**: Complete 5 study sessions in a week
- **Focused Learner**: Study for 30+ minutes without distraction

### Medals (Milestones)
- **Monthly Scholar**: Active for a full month
- **Perfect Scholar**: Achieve 100% on any quiz
- **Quiz Master**: Complete 50+ quizzes

### Ribbons (Subject Mastery)
- **English Master**: 85%+ average in English
- **Math Master**: 85%+ average in Math  
- **Science Master**: 85%+ average in Science

## Technical Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.2           # State management
  file_picker: ^8.0.7        # Document file selection
  syncfusion_flutter_pdf: ^26.2.14  # PDF processing
  archive: ^3.6.1            # PowerPoint archive handling
  xml: ^6.5.0                # PowerPoint XML parsing
  sqflite: ^2.3.3            # Local database
  http: ^1.2.2               # API requests
  google_fonts: ^6.2.1       # Typography
  font_awesome_flutter: ^10.7.0  # Icons
  lottie: ^3.1.2             # Animations
```

## Performance Considerations

- **PDF Processing**: Large PDFs are chunked for efficient processing
- **AI Requests**: Content is split to respect API limits
- **Database**: Optimized queries with proper indexing
- **Memory**: Efficient image and asset loading

## Future Enhancements

- [ ] Cloud synchronization
- [ ] Multiplayer quiz modes
- [ ] Advanced analytics dashboard
- [ ] Export/share functionality
- [ ] Voice-to-text for answers
- [ ] OCR for image-based PDFs
- [ ] Social features and leaderboards

## Troubleshooting

### Common Issues

**PDF Upload Fails:**
- Check file format (must be PDF)
- Ensure file size is reasonable
- Verify file permissions

**AI Generation Fails:**
- Check API key configuration
- Verify internet connection
- Check API rate limits

**App Crashes:**
- Clear app data
- Restart the application
- Check device storage space

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and support:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the documentation

---

**Built with ❤️ using Flutter & AI**
