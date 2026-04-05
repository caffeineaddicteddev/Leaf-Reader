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
import '../../widgets/theme_aware_switch.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    required this.bookId,
    this.initialScrollOffset,
    super.key,
  });

  final String bookId;
  final double? initialScrollOffset;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final ScrollController _scrollController = ScrollController(
    initialScrollOffset: widget.initialScrollOffset ?? 0.0,
  );
  final List<GlobalKey> _blockKeys = <GlobalKey>[];

  ProviderSubscription<AsyncValue<ReaderViewData>>? _readerViewSubscription;
  Timer? _refreshTimer;
  Timer? _saveDebounce;
  int? _lastSavedPage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
    _readerViewSubscription = ref.listenManual<AsyncValue<ReaderViewData>>(
      readerViewProvider(widget.bookId),
      (AsyncValue<ReaderViewData>? previous, AsyncValue<ReaderViewData> next) {
        // No-op: scroll position is restored via initialScrollOffset.
      },
    );
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) {
        return;
      }
      ref.read(readerRefreshProvider(widget.bookId).notifier).state++;
      ref.read(pipelineProvider(widget.bookId).notifier).continueFromReader();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No-op: listener is set up in initState.
  }

  @override
  void dispose() {
    _readerViewSubscription?.close();
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
    final AsyncValue<Book?> bookAsync = ref.watch(bookStreamProvider(widget.bookId));
    final AsyncValue<ReaderViewData> readerViewAsync = ref.watch(
      readerViewProvider(widget.bookId),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && mounted) {
          _persistVisiblePage();
          context.go(
            AppRoutes.library,
            extra: AppNavigationDirection.backward,
          );
        }
      },
      child: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            final ReaderViewData? view = readerViewAsync.valueOrNull;
            final Book? book = bookAsync.valueOrNull;
            if (view == null) {
              return readerViewAsync.when(
                skipLoadingOnRefresh: true,
                skipLoadingOnReload: true,
                data: (_) => const SizedBox.shrink(),
                error: (Object error, StackTrace stackTrace) =>
                    Center(child: Text('$error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            }

            _syncKeys(view.blocks.length);

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
              child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      floating: true,
                      pinned: false,
                      snap: false,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      leading: IconButton(
                        onPressed: () {
                          _persistVisiblePage();
                          context.go(
                            AppRoutes.library,
                            extra: AppNavigationDirection.backward,
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        tooltip: 'Back to library',
                      ),
                      titleSpacing: 0,
                      title: _ReaderTitle(book: book),
                      actions: <Widget>[
                        readerViewAsync.when(
                          skipLoadingOnRefresh: true,
                          skipLoadingOnReload: true,
                          data: (ReaderViewData view) => PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            offset: const Offset(0, 8),
                            tooltip: 'Reader options',
                            onSelected: (String value) {
                              if (value == 'toggle_ai') {
                                _toggleAiMode(!view.aiModeEnabled);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'toggle_ai',
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const Text('AI Mode'),
                                        ThemeAwareSwitch(
                                          value: view.aiModeEnabled,
                                          onChanged: (bool value) {
                                            Navigator.pop(context);
                                            _toggleAiMode(value);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                          error: (Object error, StackTrace stackTrace) =>
                              const SizedBox.shrink(),
                          loading: () => const SizedBox(width: 48),
                        ),
                      ],
                    ),
                    if (book != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 32, 22, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                book.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Inter',
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if (book.author.isNotEmpty) ...<Widget>[
                                Text(
                                  book.author,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                ),
                                const SizedBox(height: 6),
                              ],
                              Text(
                                _formatDate(book.updatedAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final int itemIndex = index ~/ 2;
                            if (index.isOdd) {
                              return const SizedBox(height: 28);
                            }

                            final ReaderBlock block = view.blocks[itemIndex];
                            return KeyedSubtree(
                              key: _blockKeys[itemIndex],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text(
                                          _pageMarkerLabel(block),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.72),
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.6,
                                                fontFamily: 'Inter',
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  SelectionArea(
                                    child: Text(
                                      block.text.isEmpty
                                          ? '[Empty page]'
                                          : block.text,
                                      style: TextStyle(
                                        fontSize: 17,
                                        height: 1.68,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: view.blocks.isEmpty
                              ? 0
                              : (view.blocks.length * 2 - 1),
                        ),
                      ),
                    ),
                    if (view.showLoading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    if (book != null && view.blocks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 48,
                            horizontal: 22,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'PAGE ${_resolveVisiblePage(view.blocks) ?? 1} OF ${book.totalPages}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.4),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2,
                                        fontFamily: 'Inter',
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: safePadding.bottom + 28),
                    ),
                  ],
                ),
              );
          },
        ),
      ),
    );
  }

  void _onScroll() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 500),
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

  String _pageMarkerLabel(ReaderBlock block) {
    if (block.sourcePages.isEmpty) {
      return 'PAGE';
    }
    final List<int> pages = List<int>.from(block.sourcePages)..sort();
    if (pages.first == pages.last) {
      return 'PAGE ${pages.first}';
    }
    return 'PAGES ${pages.first}-${pages.last}';
  }

  Future<void> _persistVisiblePage() async {
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
    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    await ref.read(bookRepositoryProvider).updateLastReadPage(
      id: widget.bookId,
      lastReadPage: visiblePage,
    );
    await ref.read(bookRepositoryProvider).updateLastScrollOffset(
      id: widget.bookId,
      lastScrollOffset: offset,
    );
    ref.invalidate(bookProvider(widget.bookId));
  }

  String _formatDate(DateTime date) {
    final List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _toggleAiMode(bool enabled) async {
    final AsyncValue<ReaderViewData> viewAsync = ref.read(
      readerViewProvider(widget.bookId),
    );
    final List<ReaderBlock> blocks =
        viewAsync.valueOrNull?.blocks ?? <ReaderBlock>[];
    final int currentPage = _resolveVisiblePage(blocks) ?? 1;
    final double offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    await ref.read(bookRepositoryProvider).updateLastReadPage(
      id: widget.bookId,
      lastReadPage: currentPage,
    );
    await ref.read(bookRepositoryProvider).updateLastScrollOffset(
      id: widget.bookId,
      lastScrollOffset: offset,
    );
    ref.invalidate(bookProvider(widget.bookId));
    await ref
        .read(pipelineProvider(widget.bookId).notifier)
        .setBookAiMode(enabled: enabled);
    ref.invalidate(continuationStateProvider(widget.bookId));
    ref.invalidate(readerViewProvider(widget.bookId));
  }
}

class _ReaderTitle extends StatelessWidget {
  const _ReaderTitle({required this.book});

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return Text(
      book?.name ?? 'Reader',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Inter',
          ),
    );
  }
}
