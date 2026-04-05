import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/processing_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../router.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  bool _didNavigateToReader = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pipelineProvider(widget.bookId).notifier).continueProcessing();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      ref.read(pipelineProvider(widget.bookId).notifier).continueProcessing();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String bookId = widget.bookId;
    final status = ref.watch(pipelineProvider(bookId));
    final bookAsync = ref.watch(bookStreamProvider(bookId));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && mounted) {
          context.go(
            AppRoutes.library,
            extra: AppNavigationDirection.backward,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go(
              AppRoutes.library,
              extra: AppNavigationDirection.backward,
            ),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to library',
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await ref.read(pipelineProvider(bookId).notifier).deleteBook();
                if (context.mounted) {
                  context.go(
                    AppRoutes.library,
                    extra: AppNavigationDirection.backward,
                  );
                }
              },
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete book',
            ),
          ],
        ),
        body: bookAsync.when(
          data: (book) {
            if (book == null) {
              return const Center(child: Text('Book not found.'));
            }
            final bool shouldOpenReader =
                !_didNavigateToReader &&
                (status.readerReady ||
                    book.status == BookProcessingState.ready);
            if (shouldOpenReader) {
              _didNavigateToReader = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go(
                    AppRoutes.reader(
                      bookId,
                      initialScrollOffset: book.lastScrollOffset,
                    ),
                    extra: AppNavigationDirection.forward,
                  );
                }
              });
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        width: 220,
                        child: const LinearProgressIndicator(minHeight: 8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      book.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _phaseLabel(status),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (status.totalPages > 0 &&
                        status.currentPage > 0 &&
                        status.phase != ProcessingPhase.done &&
                        status.phase != ProcessingPhase.error) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        _progressLabel(status),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (status.errorMessage != null &&
                        status.errorMessage!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        status.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.tonal(
                      onPressed: () async {
                        final PipelineCancelResult result = await ref
                            .read(pipelineProvider(bookId).notifier)
                            .cancelPipeline();
                        if (!context.mounted) {
                          return;
                        }
                        switch (result) {
                          case PipelineCancelResult.deleted:
                            context.go(
                              AppRoutes.library,
                              extra: AppNavigationDirection.backward,
                            );
                          case PipelineCancelResult.keptOcr:
                            context.go(
                              AppRoutes.reader(
                                bookId,
                                initialScrollOffset: book.lastScrollOffset,
                              ),
                              extra: AppNavigationDirection.forward,
                            );
                          case PipelineCancelResult.none:
                            context.go(
                              AppRoutes.library,
                              extra: AppNavigationDirection.backward,
                            );
                        }
                      },
                      child: const Text('Cancel Task'),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) =>
              Center(child: Text('$error')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  String _phaseLabel(ProcessingStatus status) {
    return switch (status.phase) {
      ProcessingPhase.downloadingLanguage => 'Preparing language data...',
      ProcessingPhase.ocr => 'Performing OCR...',
      ProcessingPhase.aiCleanup => 'Performing AI clean-up...',
      ProcessingPhase.done => 'Finishing up...',
      ProcessingPhase.error => 'Processing failed',
      ProcessingPhase.idle => 'Preparing document...',
    };
  }

  String _progressLabel(ProcessingStatus status) {
    if (status.phase == ProcessingPhase.aiCleanup && status.currentPage <= 10) {
      final int batchEnd = status.totalPages < 10 ? status.totalPages : 10;
      return 'Page 1-$batchEnd of ${status.totalPages}';
    }
    return 'Page ${status.currentPage} of ${status.totalPages}';
  }
}
