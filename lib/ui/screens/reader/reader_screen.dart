import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../../providers/reader_provider.dart';
import '../../../services/reader/reader_content_service.dart';
import '../../router.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _blockKeys = <GlobalKey>[];

  Timer? _refreshTimer;
  Timer? _saveDebounce;
  int? _pendingRestorePage;
  int? _lastSavedPage;
  bool _didInitialRestore = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(bookProvider(widget.bookId));
      ref.invalidate(continuationStateProvider(widget.bookId));
      ref.invalidate(readerViewProvider(widget.bookId));
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _refreshTimer?.cancel();
    _persistVisiblePage();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Book?> bookAsync = ref.watch(bookProvider(widget.bookId));
    final AsyncValue<ReaderViewData> readerViewAsync = ref.watch(
      readerViewProvider(widget.bookId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && mounted) {
          _persistVisiblePage();
          context.go(AppRoutes.library);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _persistVisiblePage();
              context.go(AppRoutes.library);
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to library',
          ),
          titleSpacing: 0,
          title: bookAsync.when(
            data: (Book? book) => _ReaderTitle(book: book),
            error: (Object error, StackTrace stackTrace) =>
                const _ReaderTitle(book: null),
            loading: () => const _ReaderTitle(book: null),
          ),
          actions: <Widget>[
            readerViewAsync.when(
              data: (ReaderViewData view) => PopupMenuButton<String>(
                tooltip: 'Reader options',
                onSelected: (String value) {
                  if (value == 'toggle_ai') {
                    _toggleAiMode(!view.aiModeEnabled);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  CheckedPopupMenuItem<String>(
                    value: 'toggle_ai',
                    checked: view.aiModeEnabled,
                    child: const Text('AI Mode'),
                  ),
                ],
              ),
              error: (Object error, StackTrace stackTrace) =>
                  const SizedBox.shrink(),
              loading: () => const SizedBox(width: 48),
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            final ReaderViewData? view = readerViewAsync.valueOrNull;
            if (view == null) {
              return readerViewAsync.when(
                data: (_) => const SizedBox.shrink(),
                error: (Object error, StackTrace stackTrace) =>
                    Center(child: Text('$error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            }

            final Book? book = bookAsync.valueOrNull;
            _syncKeys(view.blocks.length);
            _scheduleRestore(book, view);

            if (view.blocks.isEmpty && view.showLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (view.blocks.isEmpty) {
              return const Center(
                child: Text('No content available for this book yet.'),
              );
            }

            final EdgeInsets safePadding = MediaQuery.of(context).padding;
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  safePadding.bottom + 28,
                ),
                itemCount: view.blocks.length + (view.showLoading ? 1 : 0),
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 28),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= view.blocks.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final ReaderBlock block = view.blocks[index];
                  return KeyedSubtree(
                    key: _blockKeys[index],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${block.pageLabel}${block.aiCorrected ? ' - AI corrected' : ' - OCR'}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _onScroll() {
    if (_isRestoring || !_didInitialRestore) {
      return;
    }
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 350),
      _persistVisiblePage,
    );
  }

  void _syncKeys(int blockCount) {
    while (_blockKeys.length < blockCount) {
      _blockKeys.add(GlobalKey());
    }
    if (_blockKeys.length > blockCount) {
      _blockKeys.removeRange(blockCount, _blockKeys.length);
    }
  }

  void _scheduleRestore(Book? book, ReaderViewData view) {
    if (book == null || view.blocks.isEmpty || _isRestoring) {
      return;
    }
    final int restorePage = _pendingRestorePage ?? book.lastReadPage;
    if (_didInitialRestore && _pendingRestorePage == null) {
      return;
    }

    final int index = view.blocks.indexWhere(
      (ReaderBlock block) => block.sourcePages.contains(restorePage),
    );
    if (index == -1 && restorePage > 1) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _restoreToPage(restorePage, view);
    });
  }

  Future<void> _restoreToPage(int page, ReaderViewData view) async {
    if (_isRestoring) {
      return;
    }
    final int index = view.blocks.indexWhere(
      (ReaderBlock block) => block.sourcePages.contains(page),
    );
    final int targetIndex = index == -1 ? 0 : index;
    if (targetIndex >= _blockKeys.length) {
      return;
    }
    final BuildContext? targetContext = _blockKeys[targetIndex].currentContext;
    if (targetContext == null) {
      return;
    }
    _isRestoring = true;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 220),
      alignment: 0,
    );
    _didInitialRestore = true;
    _pendingRestorePage = null;
    _isRestoring = false;
  }

  int? _resolveVisiblePage(List<ReaderBlock> blocks) {
    if (!mounted || blocks.isEmpty) {
      return null;
    }
    final double topAnchor =
        MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    double? bestDistance;
    int? resolvedPage;
    for (int index = 0; index < blocks.length; index += 1) {
      final BuildContext? blockContext = _blockKeys[index].currentContext;
      if (blockContext == null) {
        continue;
      }
      final RenderObject? renderObject = blockContext.findRenderObject();
      if (renderObject is! RenderBox) {
        continue;
      }
      final double dy = renderObject.localToGlobal(Offset.zero).dy;
      final double distance = dy <= topAnchor
          ? topAnchor - dy
          : (dy - topAnchor) + 10000;
      if (bestDistance == null || distance < bestDistance) {
        bestDistance = distance;
        resolvedPage = blocks[index].sourcePages.first;
      }
    }
    return resolvedPage;
  }

  Future<void> _persistVisiblePage() async {
    if (!_didInitialRestore || _isRestoring) {
      return;
    }
    final AsyncValue<ReaderViewData> viewAsync = ref.read(
      readerViewProvider(widget.bookId),
    );
    final List<ReaderBlock>? blocks = viewAsync.valueOrNull?.blocks;
    if (blocks == null || blocks.isEmpty) {
      return;
    }
    final int? visiblePage = _resolveVisiblePage(blocks);
    if (visiblePage == null || visiblePage == _lastSavedPage) {
      return;
    }
    _lastSavedPage = visiblePage;
    await ref
        .read(bookRepositoryProvider)
        .updateLastReadPage(id: widget.bookId, lastReadPage: visiblePage);
    ref.invalidate(bookProvider(widget.bookId));
  }

  Future<void> _toggleAiMode(bool enabled) async {
    final AsyncValue<ReaderViewData> viewAsync = ref.read(
      readerViewProvider(widget.bookId),
    );
    final List<ReaderBlock> blocks =
        viewAsync.valueOrNull?.blocks ?? <ReaderBlock>[];
    final int currentPage = _resolveVisiblePage(blocks) ?? 1;
    _pendingRestorePage = currentPage;
    await ref
        .read(bookRepositoryProvider)
        .updateLastReadPage(id: widget.bookId, lastReadPage: currentPage);
    await ref
        .read(pipelineProvider(widget.bookId).notifier)
        .setBookAiMode(enabled: enabled);
    ref.invalidate(bookProvider(widget.bookId));
    ref.invalidate(continuationStateProvider(widget.bookId));
    ref.invalidate(readerViewProvider(widget.bookId));
  }
}

class _ReaderTitle extends StatelessWidget {
  const _ReaderTitle({required this.book});

  final Book? book;

  @override
  Widget build(BuildContext context) {
    final String? subtitle = book == null || book!.author.trim().isEmpty
        ? null
        : book!.author.trim();
    return Column(
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
        if (subtitle != null) ...<Widget>[
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
      ],
    );
  }
}
