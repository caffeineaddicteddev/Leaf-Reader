import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../widgets/leaf_bottom_nav.dart';

class ProcessingScreen extends ConsumerWidget {
  const ProcessingScreen({required this.bookId, super.key});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(pipelineProvider);
    final bookAsync = ref.watch(bookProvider(bookId));
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: const LeafBottomNav(index: 0),
      body: bookAsync.when(
        data: (book) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 84,
                  width: 84,
                  child: CircularProgressIndicator(
                    value: status.totalPages == 0
                        ? null
                        : status.currentPage / status.totalPages,
                    strokeWidth: 6,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  book?.name ?? 'Processing PDF...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Phase: ${status.phase.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(pipelineProvider.notifier).cancelPipeline(),
                  child: const Text('Cancel Task'),
                ),
              ],
            ),
          ),
        ),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
