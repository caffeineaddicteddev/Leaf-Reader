import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/processing_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../router.dart';
import '../../widgets/book_card.dart';
import '../create_book/create_book_sheet.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            showDragHandle: true,
            builder: (BuildContext context) => const CreateBookSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: booksAsync.when(
        data: (books) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Library',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search your books and documents...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (books.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No books yet')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.62,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final book = books[index];
                      final bool isInitialProcessing =
                          (book.status == BookProcessingState.processing ||
                              book.status == BookProcessingState.pending) &&
                          book.ocrProgress < 10 &&
                          book.aiProgress < 10;
                      final bool hasProcessedContent =
                          book.status == BookProcessingState.ready ||
                          book.ocrProgress >= 10 ||
                          book.aiProgress >= 10;
                      return BookCard(
                        book: book,
                        onTap: () {
                          if (isInitialProcessing) {
                            context.go(
                              AppRoutes.processing(book.id),
                              extra: AppNavigationDirection.forward,
                            );
                          } else if (hasProcessedContent) {
                            context.go(
                              AppRoutes.reader(
                                book.id,
                                initialScrollOffset: book.lastScrollOffset,
                              ),
                              extra: AppNavigationDirection.forward,
                            );
                          } else {
                            context.go(
                              AppRoutes.processing(book.id),
                              extra: AppNavigationDirection.forward,
                            );
                          }
                        },
                        onLongPressStart: (_) => _showBookMenu(context, book),
                      );
                    }, childCount: books.length),
                  ),
                ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showBookMenu(BuildContext context, Book book) async {
    final TextEditingController nameController = TextEditingController(
      text: book.name,
    );
    final TextEditingController authorController = TextEditingController(
      text: book.author,
    );
    final ValueNotifier<bool> hasChanges = ValueNotifier<bool>(false);

    void refreshDirtyState() {
      hasChanges.value =
          nameController.text.trim() != book.name ||
          authorController.text.trim() != book.author;
    }

    nameController.addListener(refreshDirtyState);
    authorController.addListener(refreshDirtyState);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Edit Book',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: hasChanges,
                  builder: (BuildContext context, bool isDirty, _) {
                    if (!isDirty) {
                      return const SizedBox(height: 16);
                    }
                    return Column(
                      children: <Widget>[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final NavigatorState navigator = Navigator.of(
                                context,
                              );
                              FocusScope.of(context).unfocus();
                              await ref
                                  .read(bookRepositoryProvider)
                                  .updateMetadata(
                                    id: book.id,
                                    name: nameController.text.trim().isEmpty
                                        ? book.name
                                        : nameController.text.trim(),
                                    author: authorController.text.trim(),
                                  );
                              ref.invalidate(booksProvider);
                              await Future<void>.delayed(Duration.zero);
                              navigator.pop();
                            },
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _deleteBook(book);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Delete Book'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    await Future<void>.delayed(Duration.zero);
    hasChanges.dispose();
    nameController.dispose();
    authorController.dispose();
  }

  Future<void> _deleteBook(Book book) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete Book'),
            content: Text('Delete "${book.name}"?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    if (book.status == BookProcessingState.processing) {
      await ref.read(pipelineProvider(book.id).notifier).deleteBook();
    } else {
      final String folderPath = await ref
          .read(fileServiceProvider)
          .getBookFolderPath(book.folderName);
      await ref.read(bookRepositoryProvider).deleteBook(book.id);
      await ref.read(fileServiceProvider).deleteBookFolder(folderPath);
    }

    ref.invalidate(booksProvider);
  }
}
