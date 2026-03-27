import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/leaf_bottom_nav.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _geminiController = TextEditingController();
  final TextEditingController _gemmaController = TextEditingController();
  bool _obscureApiKey = true;
  bool _aiMode = true;
  bool _didInitialize = false;
  bool _isSaving = false;
  String _theme = 'system';

  @override
  void dispose() {
    _apiKeyController.dispose();
    _geminiController.dispose();
    _gemmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      bottomNavigationBar: const LeafBottomNav(index: 1),
      body: settingsAsync.when(
        data: (AppSettings settings) {
          if (!_didInitialize) {
            _apiKeyController.text = settings.aiApiKey;
            _geminiController.text = settings.geminiModel;
            _gemmaController.text = settings.gemmaModel;
            _aiMode = settings.aiMode;
            _theme = settings.theme.isEmpty ? 'system' : settings.theme;
            _didInitialize = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
                title: 'AI Mode',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _aiMode
                            ? 'AI cleanup is enabled for documents and reading.'
                            : 'AI cleanup is disabled. Reader shows OCR text until AI is turned on.',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _aiMode,
                      onChanged: (bool value) {
                        setState(() {
                          _aiMode = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_aiMode)
                _SettingsCard(
                  title: 'AI Configuration',
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        decoration: InputDecoration(
                          labelText: 'Google AI Studio API Key',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureApiKey = !_obscureApiKey;
                              });
                            },
                            icon: Icon(
                              _obscureApiKey
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _geminiController,
                        decoration: const InputDecoration(
                          labelText: 'Gemini Model',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _gemmaController,
                        decoration: const InputDecoration(
                          labelText: 'Gemma Model',
                        ),
                      ),
                    ],
                  ),
                ),
              if (_aiMode) const SizedBox(height: 18),
              _SettingsCard(
                title: 'Appearance',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'light',
                        label: Text('Light'),
                      ),
                      ButtonSegment<String>(value: 'dark', label: Text('Dark')),
                      ButtonSegment<String>(
                        value: 'system',
                        label: Text('System'),
                      ),
                    ],
                    selected: <String>{_theme},
                    onSelectionChanged: (Set<String> value) {
                      setState(() {
                        _theme = value.first;
                      });
                    },
                  ),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: Text(_isSaving ? 'Saving...' : 'Save Settings'),
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

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    await repository.setValue('ai_mode', _aiMode.toString());
    await repository.setValue('ai_api_key', _apiKeyController.text.trim());
    await repository.setValue('gemini_model', _geminiController.text.trim());
    await repository.setValue('gemma_model', _gemmaController.text.trim());
    await repository.setValue('theme', _theme);
    ref.invalidate(settingsProvider);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
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
