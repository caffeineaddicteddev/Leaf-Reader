import 'processing_status.dart';

class Book {
  const Book({
    required this.id,
    required this.name,
    required this.author,
    required this.folderName,
    required this.pdfFilename,
    required this.coverPath,
    required this.totalPages,
    required this.ocrProgress,
    required this.aiProgress,
    required this.lastReadPage,
    required this.lastScrollOffset,
    required this.languageCode,
    required this.status,
    required this.fileSize,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String author;
  final String folderName;
  final String pdfFilename;
  final String? coverPath;
  final int totalPages;
  final int ocrProgress;
  final int aiProgress;
  final int lastReadPage;
  final double lastScrollOffset;
  final String languageCode;
  final BookProcessingState status;
  final int fileSize;
  final DateTime createdAt;
  final DateTime updatedAt;
}
