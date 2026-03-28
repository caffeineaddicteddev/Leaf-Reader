import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../providers/book_providers.dart';
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
  Timer? _saveDebounce;
  bool _obscureApiKey = true;
  bool _aiMode = true;
  bool _didInitialize = false;
  bool _isMigratingStorage = false;
  String _theme = 'system';

  @override
  void dispose() {
    _saveDebounce?.cancel();
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
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
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
                        _scheduleSave();
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
                        onChanged: (_) => _scheduleSave(),
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
                        onChanged: (_) => _scheduleSave(),
                        decoration: const InputDecoration(
                          labelText: 'Gemini Model',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _gemmaController,
                        onChanged: (_) => _scheduleSave(),
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
                    showSelectedIcon: false,
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
                      _scheduleSave();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SettingsCard(
                title: 'Storage',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Primary Library Path'),
                      subtitle: Text(
                        settings.libraryPath.isEmpty
                            ? 'App documents directory'
                            : settings.libraryPath,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isMigratingStorage
                            ? null
                            : () => _changeLibraryDirectory(settings),
                        icon: Icon(
                          _isMigratingStorage
                              ? Icons.sync_rounded
                              : Icons.drive_folder_upload_outlined,
                        ),
                        label: Text(
                          _isMigratingStorage
                              ? 'Migrating Library...'
                              : 'Change Directory',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'v0.1.1-alpha',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('$error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _changeLibraryDirectory(AppSettings settings) async {
    final String? selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select library folder',
    );
    if (selectedPath == null || selectedPath.trim().isEmpty) {
      return;
    }

    final SettingsRepository settingsRepository = ref.read(
      settingsRepositoryProvider,
    );
    final fileService = ref.read(fileServiceProvider);
    final bookRepository = ref.read(bookRepositoryProvider);
    final String currentLibraryRoot = await fileService.getLibraryRootPath();
    final String normalizedCurrent = p.normalize(currentLibraryRoot);
    final String normalizedSelected = p.normalize(selectedPath);
    if (normalizedCurrent == normalizedSelected) {
      return;
    }

    if (mounted) {
      setState(() {
        _isMigratingStorage = true;
      });
    }

    try {
      await fileService.migrateLibrary(newRootPath: selectedPath);
      final books = await bookRepository.getAllBooks();
      for (final book in books) {
        final String? oldCoverPath = book.coverPath;
        final String? newCoverPath = oldCoverPath == null
            ? null
            : p.join(selectedPath, book.folderName, p.basename(oldCoverPath));
        await bookRepository.updateCoverPath(
          id: book.id,
          coverPath: newCoverPath,
        );
      }
      await settingsRepository.setValue('library_path', selectedPath);
      ref.invalidate(settingsProvider);
      ref.invalidate(booksProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Library directory updated.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMigratingStorage = false;
        });
      }
    }
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), _saveSettings);
  }

  Future<void> _saveSettings() async {
    final SettingsRepository repository = ref.read(settingsRepositoryProvider);
    await repository.setValue('ai_mode', _aiMode.toString());
    await repository.setValue('ai_api_key', _apiKeyController.text.trim());
    await repository.setValue('gemini_model', _geminiController.text.trim());
    await repository.setValue('gemma_model', _gemmaController.text.trim());
    await repository.setValue('theme', _theme);
    ref.invalidate(settingsProvider);
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
