import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Extracts text content from a PDF file
  Future<String> extractTextFromPdf(File pdfFile) async {
    try {
      // Load the existing PDF document
      final PdfDocument document = PdfDocument(
        inputBytes: await pdfFile.readAsBytes(),
      );

      // Extract text from all pages
      String extractedText = '';
      for (int i = 0; i < document.pages.count; i++) {
        extractedText += PdfTextExtractor(
          document,
        ).extractText(startPageIndex: i, endPageIndex: i);
      }

      // Close the document
      document.dispose();

      return extractedText;
    } catch (e) {
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  /// Validates if a file is a valid PDF
  bool isPdfFile(String filePath) {
    return filePath.toLowerCase().endsWith('.pdf');
  }

  /// Gets PDF metadata
  Future<Map<String, dynamic>> getPdfMetadata(File pdfFile) async {
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
      };

      document.dispose();
      return metadata;
    } catch (e) {
      throw Exception('Failed to get PDF metadata: $e');
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
}
