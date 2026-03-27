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
      BookProcessingState.ready => 'Ready',
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
            onLongPress: onLongPressStart == null ? null : () {},
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Color(0xFFD8DFEC),
                            Color(0xFFC9D3E5),
                            Color(0xFFE8ECF5),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 42,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
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
