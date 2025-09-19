import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

class DocumentService {
  
  Future<String> extractTextFromDocument(File documentFile) async {
    String fileName = documentFile.path.toLowerCase();

    if (fileName.endsWith('.pdf')) {
      return await _extractTextFromPdf(documentFile);
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return await _extractTextFromPowerPoint(documentFile);
    } else {
      throw Exception(
        'Unsupported file format. Supported formats: PDF, PPT, PPTX',
      );
    }
  }

  /// Extracts text content from a PDF file
  Future<String> _extractTextFromPdf(File pdfFile) async {
    try {
      // Load the existing PDF document
      final PdfDocument document = PdfDocument(
        inputBytes: await pdfFile.readAsBytes(),
      );

      
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        extractedText += PdfTextExtractor(
          document,
        ).extractText(startPageIndex: i, endPageIndex: i);
        extractedText += '\n';
      }

      
      document.dispose();

      return extractedText;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Extracts text content from a PowerPoint file (PPT/PPTX)
  Future<String> _extractTextFromPowerPoint(File pptFile) async {
    try {
      String fileName = pptFile.path.toLowerCase();

      if (fileName.endsWith('.pptx')) {
        return await _extractTextFromPptx(pptFile);
      } else if (fileName.endsWith('.ppt')) {
        
        throw Exception(
          'Legacy .ppt files are not fully supported. Please convert to .pptx format.',
        );
      } else {
        throw Exception('Invalid PowerPoint file format');
      }
    } catch (e) {
      throw Exception('Failed to extract text from PowerPoint: $e');
    }
  }

  /// Extracts text from PPTX files
  Future<String> _extractTextFromPptx(File pptxFile) async {
    try {
      // Read the PPTX file as bytes
      Uint8List bytes = await pptxFile.readAsBytes();

      
      Archive archive = ZipDecoder().decodeBytes(bytes);

      String extractedText = '';
      int slideNumber = 1;

      
      for (ArchiveFile file in archive) {
        if (file.name.startsWith('ppt/slides/slide') &&
            file.name.endsWith('.xml')) {
          String slideContent = await _extractTextFromSlideXml(file);
          if (slideContent.isNotEmpty) {
            extractedText += '--- Slide $slideNumber ---\n';
            extractedText += slideContent;
            extractedText += '\n\n';
            slideNumber++;
          }
        }
      }

      
      for (ArchiveFile file in archive) {
        if (file.name.startsWith('ppt/notesSlides/notesSlide') &&
            file.name.endsWith('.xml')) {
          String notesContent = await _extractTextFromNotesXml(file);
          if (notesContent.isNotEmpty) {
            extractedText += '--- Speaker Notes ---\n';
            extractedText += notesContent;
            extractedText += '\n\n';
          }
        }
      }

      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to parse PPTX file: $e');
    }
  }

  
  Future<String> _extractTextFromSlideXml(ArchiveFile slideFile) async {
    try {
      String xmlContent = String.fromCharCodes(slideFile.content);
      XmlDocument document = XmlDocument.parse(xmlContent);

      String slideText = '';

      
      var textElements = document.findAllElements('a:t');
      for (var element in textElements) {
        String text = element.innerText.trim();
        if (text.isNotEmpty) {
          slideText += text + ' ';
        }
      }

      return slideText.trim();
    } catch (e) {
      
      return '';
    }
  }

  /// Extracts text from notes XML file
  Future<String> _extractTextFromNotesXml(ArchiveFile notesFile) async {
    try {
      String xmlContent = String.fromCharCodes(notesFile.content);
      XmlDocument document = XmlDocument.parse(xmlContent);

      String notesText = '';

      // Find all text elements in notes
      var textElements = document.findAllElements('a:t');
      for (var element in textElements) {
        String text = element.innerText.trim();
        if (text.isNotEmpty) {
          notesText += text + ' ';
        }
      }

      return notesText.trim();
    } catch (e) {
      return '';
    }
  }

  /// Validates if a file is a supported document format
  bool isSupportedDocument(String filePath) {
    String fileName = filePath.toLowerCase();
    return fileName.endsWith('.pdf') ||
        fileName.endsWith('.ppt') ||
        fileName.endsWith('.pptx');
  }

  /// Gets document metadata
  Future<Map<String, dynamic>> getDocumentMetadata(File documentFile) async {
    String fileName = documentFile.path.toLowerCase();

    if (fileName.endsWith('.pdf')) {
      return await _getPdfMetadata(documentFile);
    } else if (fileName.endsWith('.pptx')) {
      return await _getPptxMetadata(documentFile);
    } else {
      // Basic metadata for unsupported formats
      return {
        'fileName': documentFile.path.split('/').last,
        'fileSize': await documentFile.length(),
        'type': 'PowerPoint',
        'lastModified': await documentFile.lastModified(),
      };
    }
  }

  /// Gets PDF metadata
  Future<Map<String, dynamic>> _getPdfMetadata(File pdfFile) async {
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: await pdfFile.readAsBytes(),
      );

      final metadata = {
        'pageCount': document.pages.count,
        'title': document.documentInformation.title,
        'author': document.documentInformation.author,
        'subject': document.documentInformation.subject,
        'keywords': document.documentInformation.keywords,
        'creator': document.documentInformation.creator,
        'producer': document.documentInformation.producer,
        'creationDate': document.documentInformation.creationDate,
        'modificationDate': document.documentInformation.modificationDate,
        'type': 'PDF',
        'fileName': pdfFile.path.split('/').last,
        'fileSize': await pdfFile.length(),
      };

      document.dispose();
      return metadata;
    } catch (e) {
      throw Exception('Failed to get PDF metadata: $e');
    }
  }

  /// Gets PPTX metadata
  Future<Map<String, dynamic>> _getPptxMetadata(File pptxFile) async {
    try {
      Uint8List bytes = await pptxFile.readAsBytes();
      Archive archive = ZipDecoder().decodeBytes(bytes);

      int slideCount = 0;
      String title = '';
      String author = '';

      // Count slides
      for (ArchiveFile file in archive) {
        if (file.name.startsWith('ppt/slides/slide') &&
            file.name.endsWith('.xml')) {
          slideCount++;
        }
      }

      // Try to get metadata from core.xml
      for (ArchiveFile file in archive) {
        if (file.name == 'docProps/core.xml') {
          try {
            String xmlContent = String.fromCharCodes(file.content);
            XmlDocument document = XmlDocument.parse(xmlContent);

            var titleElement = document.findAllElements('dc:title').firstOrNull;
            if (titleElement != null) {
              title = titleElement.innerText;
            }

            var creatorElement = document
                .findAllElements('dc:creator')
                .firstOrNull;
            if (creatorElement != null) {
              author = creatorElement.innerText;
            }
          } catch (e) {
            // Ignore metadata parsing errors
          }
        }
      }

      return {
        'slideCount': slideCount,
        'title': title.isEmpty ? 'Unknown' : title,
        'author': author.isEmpty ? 'Unknown' : author,
        'type': 'PowerPoint',
        'fileName': pptxFile.path.split('/').last,
        'fileSize': await pptxFile.length(),
        'lastModified': await pptxFile.lastModified(),
      };
    } catch (e) {
      throw Exception('Failed to get PPTX metadata: $e');
    }
  }

  /// Cleans and preprocesses extracted text
  String preprocessText(String rawText) {
    // Remove excessive whitespace
    String cleanText = rawText.replaceAll(RegExp(r'\s+'), ' ');

    // Remove unwanted special characters but keep basic punctuation
    cleanText = cleanText.replaceAll(
      RegExp(r'[^\w\s\.\,\!\?\;\:\-\(\)\[\]]+'),
      '',
    );

    // Ensure proper sentence structure
    cleanText = cleanText.replaceAll(RegExp(r'\.(?!\s)'), '. ');

    // Remove slide separators for cleaner text
    cleanText = cleanText.replaceAll(RegExp(r'--- Slide \d+ ---'), '');
    cleanText = cleanText.replaceAll(RegExp(r'--- Speaker Notes ---'), '');

    return cleanText.trim();
  }

  /// Splits text into chunks for better AI processing
  List<String> splitTextIntoChunks(String text, {int maxChunkSize = 3000}) {
    if (text.length <= maxChunkSize) {
      return [text];
    }

    List<String> chunks = [];
    List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    String currentChunk = '';

    for (String sentence in sentences) {
      if ((currentChunk + sentence).length <= maxChunkSize) {
        currentChunk += (currentChunk.isEmpty ? '' : ' ') + sentence;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk);
          currentChunk = sentence;
        } else {
          // If a single sentence is too long, split it by words
          List<String> words = sentence.split(' ');
          String wordChunk = '';

          for (String word in words) {
            if ((wordChunk + word).length <= maxChunkSize) {
              wordChunk += (wordChunk.isEmpty ? '' : ' ') + word;
            } else {
              if (wordChunk.isNotEmpty) {
                chunks.add(wordChunk);
                wordChunk = word;
              }
            }
          }

          if (wordChunk.isNotEmpty) {
            currentChunk = wordChunk;
          }
        }
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks;
  }

  /// Gets the document type from file extension
  String getDocumentType(String filePath) {
    String fileName = filePath.toLowerCase();

    if (fileName.endsWith('.pdf')) {
      return 'PDF';
    } else if (fileName.endsWith('.ppt') || fileName.endsWith('.pptx')) {
      return 'PowerPoint';
    } else {
      return 'Unknown';
    }
  }

  /// Gets supported file extensions
  List<String> getSupportedExtensions() {
    return ['pdf', 'ppt', 'pptx'];
  }

  /// Gets file picker allowed extensions
  List<String> getFilePickerExtensions() {
    return ['pdf', 'ppt', 'pptx'];
  }
}
