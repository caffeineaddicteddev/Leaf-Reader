import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/processing_status.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../router.dart';
import '../../widgets/book_card.dart';
import '../../widgets/leaf_bottom_nav.dart';
import '../create_book/create_book_sheet.dart';

enum _BookCardAction { edit, delete }

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
      bottomNavigationBar: const LeafBottomNav(index: 0),
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
                          fillColor: Theme.of(context).colorScheme.surface,
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
                          childAspectRatio: 0.68,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final book = books[index];
                      final bool readerAvailable =
                          book.status == BookProcessingState.ready ||
                          book.aiProgress >=
                              (book.totalPages < 10 ? book.totalPages : 10);
                      return BookCard(
                        book: book,
                        onTap: () => context.go(
                          readerAvailable
                              ? AppRoutes.reader(book.id)
                              : AppRoutes.processing(book.id),
                        ),
                        onLongPressStart: (LongPressStartDetails details) {
                          _showBookMenu(context, details.globalPosition, book);
                        },
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

  Future<void> _showBookMenu(
    BuildContext context,
    Offset globalPosition,
    Book book,
  ) async {
    final OverlayState overlay = Overlay.of(context);
    final _BookCardAction? action = await showMenu<_BookCardAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 1, 1),
        Offset.zero & overlay.context.size!,
      ),
      items: const <PopupMenuEntry<_BookCardAction>>[
        PopupMenuItem<_BookCardAction>(
          value: _BookCardAction.edit,
          child: Text('Edit'),
        ),
        PopupMenuItem<_BookCardAction>(
          value: _BookCardAction.delete,
          child: Text('Delete'),
        ),
      ],
    );

    switch (action) {
      case _BookCardAction.edit:
        await _showEditDialog(book);
      case _BookCardAction.delete:
        await _deleteBook(book);
      case null:
        break;
    }
  }

  Future<void> _showEditDialog(Book book) async {
    final TextEditingController nameController = TextEditingController(
      text: book.name,
    );
    final TextEditingController authorController = TextEditingController(
      text: book.author,
    );
    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
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
      ref.invalidate(bookProvider(book.id));
    }
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
    ref.invalidate(bookProvider(book.id));
  }
}
