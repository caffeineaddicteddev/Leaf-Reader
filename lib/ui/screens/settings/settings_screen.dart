import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/theme_aware_switch.dart';

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
  bool _aiMode = false;
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
    final colorScheme = Theme.of(context).colorScheme;
    final Color scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;

    // Design Colors adapted to current theme
    final Color onSurface = colorScheme.onSurface;
    final Color onSurfaceVariant = colorScheme.onSurfaceVariant;
    final Color primary = colorScheme.primary;
    final Color onPrimary = colorScheme.onPrimary;
    final Color secondary = colorScheme.secondary;
    final Color onSecondary = colorScheme.onSecondary;
    final Color surfaceContainerLow = colorScheme.surfaceContainerLow;
    final Color surfaceContainerLowest = colorScheme.surfaceContainer; // Changed to match theme standard
    final Color surfaceContainerHigh = colorScheme.surfaceContainerHigh;
    final Color surfaceContainerHighest = colorScheme.surfaceContainerHighest;
    final Color outlineVariant = colorScheme.outlineVariant;

    return Scaffold(
      backgroundColor: scaffoldBackground,
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
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
            children: <Widget>[
              // Page Title
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Appearance Section
              _buildSectionHeader(Icons.palette_outlined, 'APPEARANCE', primary, onSurfaceVariant),
              _buildSectionContainer(
                surfaceContainerLow: surfaceContainerLow,
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: <Widget>[
                    _buildThemeButton('light', Icons.light_mode_outlined, 'Light', primary, onPrimary, surfaceContainerHigh, onSurfaceVariant),
                    _buildThemeButton('dark', Icons.dark_mode_outlined, 'Dark', primary, onPrimary, surfaceContainerHigh, onSurfaceVariant),
                    _buildThemeButton(
                      'system',
                      Icons.settings_brightness_outlined,
                      'System',
                      primary,
                      onPrimary,
                      surfaceContainerHigh,
                      onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // AI Mode Section (Functional requirement)
              _buildSectionHeader(Icons.auto_awesome_outlined, 'AI MODE', primary, onSurfaceVariant),
              _buildSectionContainer(
                surfaceContainerLow: surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _aiMode
                              ? 'AI cleanup is enabled for documents and reading.'
                              : 'AI cleanup is disabled. Reader shows OCR text until AI is turned on.',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ThemeAwareSwitch(
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
              ),
              const SizedBox(height: 32),

              // AI Configuration Section
              if (_aiMode) ...[
                _buildSectionHeader(Icons.psychology_outlined, 'AI CONFIGURATION', primary, onSurfaceVariant),
                _buildSectionContainer(
                  surfaceContainerLow: surfaceContainerLow,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildInputFieldLabel('API KEY', onSurfaceVariant),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        onChanged: (_) => _scheduleSave(),
                        suffixIcon:
                            _obscureApiKey
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                        onSuffixPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                        surfaceContainerHighest: surfaceContainerHighest,
                        onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                        outlineVariant: outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      _buildInputFieldLabel('GEMINI MODEL', onSurfaceVariant),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _geminiController,
                        onChanged: (_) => _scheduleSave(),
                        suffixIcon: Icons.expand_more,
                        surfaceContainerHighest: surfaceContainerHighest,
                        onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                        outlineVariant: outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      _buildInputFieldLabel('GEMMA MODEL', onSurfaceVariant),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _gemmaController,
                        onChanged: (_) => _scheduleSave(),
                        suffixIcon: Icons.expand_more,
                        surfaceContainerHighest: surfaceContainerHighest,
                        onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                        outlineVariant: outlineVariant,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: onSecondary,
                            minimumSize: const Size.fromHeight(48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: secondary.withValues(alpha: 0.2),
                            ),
                          ),
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text(
                            'Save AI configuration',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Storage Section
              _buildSectionHeader(Icons.folder_shared_outlined, 'STORAGE', primary, onSurfaceVariant),
              _buildSectionContainer(
                surfaceContainerLow: surfaceContainerLow,
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primary Library Path',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'All processed PDFs and OCR data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.storage_rounded,
                            color: primary.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap:
                              _isMigratingStorage
                                  ? null
                                  : () => _changeLibraryDirectory(settings),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: outlineVariant.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  color: onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    settings.libraryPath.isEmpty
                                        ? 'App documents directory'
                                        : settings.libraryPath,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: onSurfaceVariant,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: onSurfaceVariant.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isMigratingStorage
                                  ? null
                                  : () => _changeLibraryDirectory(settings),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: onSecondary,
                            disabledBackgroundColor: surfaceContainerHigh,
                            disabledForegroundColor: onSurfaceVariant,
                            minimumSize: const Size.fromHeight(48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: secondary.withValues(alpha: 0.2),
                            ),
                          ),
                          icon: Icon(
                            _isMigratingStorage
                                ? Icons.sync_rounded
                                : Icons.folder_open_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _isMigratingStorage
                                ? 'Migrating Library...'
                                : 'Change Saved Directory',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Footer
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'v0.2.0-alpha',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: outlineVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Created by Sajid',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed:
                        () => _launchUrl(
                          'https://github.com/caffeineaddicteddev/Leaf-Reader',
                        ),
                    icon: Opacity(
                      opacity: 0.6,
                      child: SvgPicture.string(
                        '<svg height="20" viewBox="0 0 16 16" width="20" xmlns="http://www.w3.org/2000/svg"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" fill="currentColor" /></svg>',
                        colorFilter: ColorFilter.mode(
                          onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
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

  Widget _buildSectionHeader(IconData icon, String title, Color primary, Color onSurfaceVariant) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child, EdgeInsets? padding, required Color surfaceContainerLow}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: child,
    );
  }

  Widget _buildThemeButton(String value, IconData icon, String label, Color primary, Color onPrimary, Color surfaceContainerHigh, Color onSurfaceVariant) {
    final bool isSelected = _theme == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _theme = value;
        });
        _scheduleSave();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? primary : surfaceContainerHigh,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(
            color:
                isSelected
                    ? onPrimary.withValues(alpha: 0.12)
                    : onSurfaceVariant.withValues(alpha: 0.22),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? onPrimary : onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? onPrimary : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFieldLabel(String label, Color onSurfaceVariant) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixPressed,
    void Function(String)? onChanged,
    bool enabled = true,
    required Color surfaceContainerHighest,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outlineVariant,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        enabled: enabled,
        style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: outlineVariant, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon:
              suffixIcon != null
                  ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: onSurfaceVariant.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onPressed: onSuffixPressed,
                  )
                  : null,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  Future<void> _changeLibraryDirectory(AppSettings settings) async {
    if (Platform.isAndroid) {
      final statusManage = await Permission.manageExternalStorage.request();
      final statusStorage = await Permission.storage.request();
      if (!statusManage.isGranted && !statusStorage.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to change library directory.')),
          );
        }
        return;
      }
    }

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
        final String? newCoverPath =
            oldCoverPath == null
                ? null
                : p.join(
                  selectedPath,
                  book.folderName,
                  p.basename(oldCoverPath),
                );
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
