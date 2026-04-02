import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/models/book.dart';
import '../../domain/models/processing_status.dart';
import 'progress_ring.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    required this.book,
    required this.onTap,
    this.onLongPressStart,
    super.key,
  });

  final Book book;
  final VoidCallback onTap;
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String statusLabel = switch (book.status) {
      BookProcessingState.processing => 'Processing',
      BookProcessingState.ready => '${book.lastReadPage} / ${book.totalPages}',
      BookProcessingState.error => 'Error',
      BookProcessingState.pending => 'Pending',
    };
    final int completedPages = switch (book.status) {
      BookProcessingState.ready =>
        book.aiProgress > 0 ? book.aiProgress : book.ocrProgress,
      BookProcessingState.processing =>
        book.aiProgress > 0 ? book.aiProgress : book.ocrProgress,
      _ => 0,
    };
    final double progress = book.totalPages == 0
        ? 0.0
        : completedPages / book.totalPages;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        onLongPressStart: onLongPressStart,
        child: Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: _BookCover(
                      coverPath: book.coverPath,
                      progress: progress,
                      statusColor: theme.colorScheme.primary,
                      showProgress: book.status == BookProcessingState.processing || book.status == BookProcessingState.pending,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    book.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author.isEmpty ? 'Unknown author' : book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.coverPath,
    required this.progress,
    required this.statusColor,
    required this.showProgress,
  });

  final String? coverPath;
  final double progress;
  final Color statusColor;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final File? coverFile = coverPath == null ? null : File(coverPath!);
    final bool hasCover = coverFile != null && coverFile.existsSync();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (hasCover)
            Image.file(coverFile, fit: BoxFit.cover)
          else
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? <Color>[
                          const Color(0xFF27272A), // Zinc-800
                          const Color(0xFF18181B), // Zinc-900
                          const Color(0xFF09090B), // Zinc-950
                        ]
                      : <Color>[
                          const Color(0xFFE2E8F0),
                          const Color(0xFFCBD5E1),
                          const Color(0xFFF1F5F9),
                        ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 42,
                  color: statusColor.withValues(alpha: 0.45),
                ),
              ),
            ),
          if (showProgress)
            Positioned(
              top: 10,
              right: 10,
              child: SizedBox(
                height: 36,
                width: 36,
                child: ProgressRing(progress: progress),
              ),
            ),
        ],
      ),
    );
  }
}
