import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/processing_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../../providers/reader_provider.dart';
import '../../router.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(bookProvider(widget.bookId));
      ref.invalidate(readerBlocksProvider(widget.bookId));
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookProvider(widget.bookId));
    final blocksAsync = ref.watch(readerBlocksProvider(widget.bookId));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && mounted) {
          context.go(AppRoutes.library);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.library),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to library',
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                bookAsync.valueOrNull?.name ?? 'Reader',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitleForBook(bookAsync.valueOrNull),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.64),
                ),
              ),
            ],
          ),
          actions: const <Widget>[
            SizedBox(width: 8),
            Icon(Icons.more_vert),
            SizedBox(width: 12),
          ],
        ),
        body: Container(
          color: const Color(0xFFF7F5F0),
          child: blocksAsync.when(
            data: (blocks) {
              if (blocks.isEmpty) {
                return const Center(
                  child: Text('No OCR content available for this book yet.'),
                );
              }
              final EdgeInsets safePadding = MediaQuery.of(context).padding;
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  safePadding.bottom + 28,
                ),
                itemCount: blocks.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 28),
                itemBuilder: (BuildContext context, int index) {
                  final block = blocks[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${block.pageLabel}${block.aiCorrected ? ' - AI corrected' : ' - OCR'}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SelectionArea(
                        child: Text(
                          block.text.isEmpty ? '[Empty page]' : block.text,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.68,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            error: (Object error, StackTrace stackTrace) =>
                Center(child: Text('$error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  String _subtitleForBook(Book? book) {
    if (book == null) {
      return 'OCR EXTRACTED';
    }
    if (book.status == BookProcessingState.processing) {
      final int completedPages = book.aiProgress > 0
          ? book.aiProgress
          : book.ocrProgress;
      return '$completedPages/${book.totalPages} pages';
    }
    return 'OCR EXTRACTED';
  }
}
