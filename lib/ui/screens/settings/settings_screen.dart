import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_provider.dart';
import '../../widgets/leaf_bottom_nav.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      bottomNavigationBar: const LeafBottomNav(index: 1),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: <Widget>[
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Refine your digital archive experience',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _SettingsCard(
              title: 'AI Configuration',
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('API Key'),
                    subtitle: Text(
                      settings.aiApiKey.isEmpty
                          ? 'Not configured'
                          : 'Configured',
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gemini Model'),
                    subtitle: Text(settings.geminiModel),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gemma Model'),
                    subtitle: Text(settings.gemmaModel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: 'Appearance',
              child: SegmentedButton<int>(
                segments: const <ButtonSegment<int>>[
                  ButtonSegment<int>(value: 0, label: Text('Light')),
                  ButtonSegment<int>(value: 1, label: Text('Dark')),
                  ButtonSegment<int>(value: 2, label: Text('System')),
                ],
                selected: const <int>{2},
              ),
            ),
            const SizedBox(height: 18),
            _SettingsCard(
              title: 'Storage',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Primary Library Path'),
                subtitle: Text(
                  settings.libraryPath.isEmpty
                      ? 'App documents directory'
                      : settings.libraryPath,
                ),
              ),
            ),
          ],
        ),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
