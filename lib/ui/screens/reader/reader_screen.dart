import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../providers/reader_provider.dart';
import '../../../providers/settings_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.bookId, super.key});

  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _initializedToggle = false;

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

    return Scaffold(
      appBar: AppBar(
        title: bookAsync.maybeWhen(
          data: (book) => Text(book?.name ?? 'Reader'),
          orElse: () => const Text('Reader'),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              const Text('AI'),
              Switch(
                value: aiEnabled,
                onChanged: (bool value) async {
                  ref
                          .read(readerAiToggleProvider(widget.bookId).notifier)
                          .state =
                      value;
                  if (value) {
                    await ref
                        .read(
                          readerAiControllerProvider(widget.bookId).notifier,
                        )
                        .enableAi(widget.bookId);
                  }
                  ref.invalidate(readerBlocksProvider(widget.bookId));
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: const Color(0xFFF8F7F4),
        child: blocksAsync.when(
          data: (blocks) {
            if (blocks.isEmpty) {
              return const Center(
                child: Text('No OCR content available for this book yet.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              itemCount: blocks.length + (aiRunState.isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 32),
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
                      'Page ${block.page}${block.aiCorrected ? ' - AI corrected' : ' - OCR'}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      block.text.isEmpty ? '[Empty page]' : block.text,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.7,
                        color: Color(0xFF2C2C2A),
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
    );
  }
}
