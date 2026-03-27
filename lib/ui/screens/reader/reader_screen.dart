import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/processing_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/reader_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../router.dart';

enum _ReaderMenuAction { toggleAi }

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _initializedToggle = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(bookProvider(widget.bookId));
      ref.invalidate(readerBlocksProvider(widget.bookId));
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
    final settingsAsync = ref.watch(settingsProvider);
    final aiRunState = ref.watch(readerAiControllerProvider(widget.bookId));

    settingsAsync.whenData((AppSettings settings) {
      if (!_initializedToggle) {
        ref.read(readerAiToggleProvider(widget.bookId).notifier).state =
            settings.aiMode;
        _initializedToggle = true;
      }
    });

    final bool aiEnabled = ref.watch(readerAiToggleProvider(widget.bookId));
    final blocksAsync = ref.watch(readerBlocksProvider(widget.bookId));
    final book = bookAsync.valueOrNull;
    final String subtitle = _subtitleForBook(book, aiEnabled);

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
                book?.name ?? 'Reader',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
          actions: <Widget>[
            PopupMenuButton<_ReaderMenuAction>(
              onSelected: (_ReaderMenuAction action) async {
                switch (action) {
                  case _ReaderMenuAction.toggleAi:
                    final bool newValue = !aiEnabled;
                    ref
                            .read(
                              readerAiToggleProvider(widget.bookId).notifier,
                            )
                            .state =
                        newValue;
                    if (newValue) {
                      await ref
                          .read(
                            readerAiControllerProvider(widget.bookId).notifier,
                          )
                          .enableAi(widget.bookId);
                    }
                    ref.invalidate(readerBlocksProvider(widget.bookId));
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<_ReaderMenuAction>>[
                    CheckedPopupMenuItem<_ReaderMenuAction>(
                      value: _ReaderMenuAction.toggleAi,
                      checked: aiEnabled,
                      child: const Text('AI cleanup'),
                    ),
                  ],
              icon: const Icon(Icons.more_vert),
            ),
            const SizedBox(width: 4),
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
                itemCount: blocks.length + (aiRunState.isLoading ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 28),
                itemBuilder: (BuildContext context, int index) {
                  if (aiRunState.isLoading && index == blocks.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
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

  String _subtitleForBook(Book? book, bool aiEnabled) {
    if (book == null) {
      return 'OCR EXTRACTED';
    }
    if (book.status == BookProcessingState.processing) {
      final String progress = book.totalPages == 0
          ? 'processing'
          : '${book.aiProgress > 0 ? book.aiProgress : book.ocrProgress}/${book.totalPages} pages';
      return aiEnabled
          ? 'AI CLEAN-UP ON  •  $progress'
          : 'OCR EXTRACTED  •  $progress';
    }
    return aiEnabled ? 'AI CLEAN-UP ON' : 'OCR EXTRACTED';
  }
}
