import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';
import '../providers/quiz_provider.dart';
import '../services/document_service.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  File? _selectedFile;
  Uint8List? _selectedFileBytes; // For web compatibility
  String? _selectedFileName;
  String _quizTitle = '';
  int _numberOfQuestions = 10;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  final Set<QuestionType> _selectedQuestionTypes = {
    QuestionType.multipleChoice,
  };

  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DocumentService _documentService = DocumentService();

  bool _isGenerating = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz from Document'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Upload Section
              _buildDocumentUploadSection(),

              const SizedBox(height: 24),

              // Quiz Configuration Section
              if (_selectedFile != null || _selectedFileBytes != null) ...[
                _buildQuizConfigurationSection(),

                const SizedBox(height: 32),

                // Generate Quiz Button
                _buildGenerateButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Document',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: PDF, PowerPoint (PPT, PPTX)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            if (_selectedFile == null && _selectedFileBytes == null) ...[
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: InkWell(
                  onTap: _pickDocumentFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to upload document',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDF, PPT, PPTX files supported',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(_getSelectedFileName()),
                      color: _getFileIconColor(_getSelectedFileName()),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSelectedFileName(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${_getFileType(_getSelectedFileName())} file ready for processing',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedFile = null;
                        _selectedFileBytes = null;
                        _selectedFileName = null;
                      }),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickDocumentFile,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Choose Different File'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizConfigurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Configuration',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Quiz Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                hintText: 'Enter a title for your quiz',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a quiz title';
                }
                return null;
              },
              onChanged: (value) => _quizTitle = value,
            ),

            const SizedBox(height: 20),

            // Number of Questions
            Text(
              'Number of Questions: $_numberOfQuestions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _numberOfQuestions.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: '$_numberOfQuestions',
              onChanged: (value) =>
                  setState(() => _numberOfQuestions = value.round()),
            ),

            const SizedBox(height: 20),

            // Difficulty Level
            Text(
              'Difficulty Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<DifficultyLevel>(
              segments: const [
                ButtonSegment(
                  value: DifficultyLevel.easy,
                  label: Text('Easy'),
                  icon: Icon(Icons.sentiment_satisfied),
                ),
                ButtonSegment(
                  value: DifficultyLevel.medium,
                  label: Text('Medium'),
                  icon: Icon(Icons.sentiment_neutral),
                ),
                ButtonSegment(
                  value: DifficultyLevel.hard,
                  label: Text('Hard'),
                  icon: Icon(Icons.sentiment_very_dissatisfied),
                ),
              ],
              selected: {_difficulty},
              onSelectionChanged: (selection) =>
                  setState(() => _difficulty = selection.first),
            ),

            const SizedBox(height: 20),

            // Question Types
            Text(
              'Question Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Multiple Choice'),
                  selected: _selectedQuestionTypes.contains(
                    QuestionType.multipleChoice,
                  ),
                  onSelected: (selected) => _toggleQuestionType(
                    QuestionType.multipleChoice,
                    selected,
                  ),
                ),
                FilterChip(
                  label: const Text('True/False'),
                  selected: _selectedQuestionTypes.contains(
                    QuestionType.trueFalse,
                  ),
                  onSelected: (selected) =>
                      _toggleQuestionType(QuestionType.trueFalse, selected),
                ),
                FilterChip(
                  label: const Text('Enumeration'),
                  selected: _selectedQuestionTypes.contains(
                    QuestionType.enumeration,
                  ),
                  onSelected: (selected) =>
                      _toggleQuestionType(QuestionType.enumeration, selected),
                ),
              ],
            ),

            if (_selectedQuestionTypes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one question type',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final isLoading = quizProvider.isLoading || _isGenerating;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading || _selectedQuestionTypes.isEmpty
                ? null
                : _generateQuiz,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isLoading ? 'Generating Quiz...' : 'Generate Quiz'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDocumentFile() async {
    try {
      // Show web warning if on web platform
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Web file upload is currently limited. For full functionality, please use the mobile or desktop app.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _documentService.getFilePickerExtensions(),
        allowMultiple: false,
        withData: kIsWeb, // Load file bytes for web
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        final pickedFile = result.files.single;

        // Store file name for validation
        _selectedFileName = pickedFile.name;

        // Validate file format using file name
        if (!_documentService.isSupportedDocument(_selectedFileName!)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Unsupported file format. Please select a PDF, PPT, or PPTX file.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (kIsWeb) {
          // Web platform: use bytes
          if (pickedFile.bytes != null) {
            _selectedFileBytes = pickedFile.bytes!;
            setState(() {
              _selectedFile = null; // Clear file object for web
            });
          } else {
            throw Exception('Failed to load file data on web platform');
          }
        } else {
          // Mobile/Desktop platform: use file path
          if (pickedFile.path != null) {
            setState(() {
              _selectedFile = File(pickedFile.path!);
              _selectedFileBytes = null; // Clear bytes for mobile
            });
          } else {
            throw Exception('Failed to get file path on mobile platform');
          }
        }

        // Auto-generate title from filename if empty
        if (_titleController.text.isEmpty) {
          final fileName = pickedFile.name;
          final nameWithoutExtension = fileName.substring(
            0,
            fileName.lastIndexOf('.'),
          );
          _titleController.text = nameWithoutExtension;
          _quizTitle = nameWithoutExtension;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleQuestionType(QuestionType type, bool selected) {
    setState(() {
      if (selected) {
        _selectedQuestionTypes.add(type);
      } else {
        _selectedQuestionTypes.remove(type);
      }
    });
  }

  Future<void> _generateQuiz() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedFile == null && _selectedFileBytes == null)) {
      return;
    }

    setState(() => _isGenerating = true);

    try {
      Quiz? quiz;

      if (kIsWeb) {
        // For web, show a message that file upload from web is not fully supported yet
        throw Exception(
          'Web file upload is not fully supported yet. Please use the mobile or desktop app.',
        );
      } else if (_selectedFile != null) {
        // Mobile/Desktop platform: create quiz from file
        quiz = await context.read<QuizProvider>().createQuizFromDocument(
          documentFile: _selectedFile!,
          title: _quizTitle.trim(),
          numberOfQuestions: _numberOfQuestions,
          questionTypes: _selectedQuestionTypes.toList(),
          difficulty: _difficulty,
        );
      }

      if (mounted) {
        setState(() => _isGenerating = false);

        if (quiz != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create quiz. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Helper methods for file type detection
  String _getSelectedFileName() {
    if (kIsWeb && _selectedFileName != null) {
      return _selectedFileName!;
    } else if (_selectedFile != null) {
      return _selectedFile!.path.split('/').last;
    }
    return 'Unknown file';
  }

  IconData _getFileIcon(String filePath) {
    String fileName = filePath.toLowerCase();
    if (fileName.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Icons.slideshow;
    }
    return Icons.description;
  }

  Color _getFileIconColor(String filePath) {
    String fileName = filePath.toLowerCase();
    if (fileName.endsWith('.pdf')) {
      return Colors.red[700]!;
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return Colors.orange[700]!;
    }
    return Colors.blue[700]!;
  }

  String _getFileType(String filePath) {
    return _documentService.getDocumentType(filePath);
  }
}
