import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../data/database/app_database.dart';
import '../../../data/json/clean_json_manager.dart';
import '../../../data/json/ocr_json_manager.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/pipeline_provider.dart';
import '../../router.dart';
import '../../widgets/language_dropdown.dart';

class CreateBookSheet extends ConsumerStatefulWidget {
  const CreateBookSheet({super.key});

  @override
  ConsumerState<CreateBookSheet> createState() => _CreateBookSheetState();
}

class _CreateBookSheetState extends ConsumerState<CreateBookSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  String _languageCode = 'ben';
  String? _pdfPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Create Book',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 12),
            LanguageDropdown(
              value: _languageCode,
              onChanged: (String? value) {
                setState(() {
                  _languageCode = value ?? 'ben';
                });
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(
                _pdfPath == null ? 'Choose PDF' : p.basename(_pdfPath!),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : () => _createBook(context),
                child: Text(_isSaving ? 'Creating...' : 'Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf'],
    );
    if (result == null || result.files.single.path == null) {
      return;
    }
    setState(() {
      _pdfPath = result.files.single.path;
    });
  }

  Future<void> _createBook(BuildContext context) async {
    if (_nameController.text.trim().isEmpty || _pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and PDF are required.')),
      );
      return;
    }

    final NavigatorState navigator = Navigator.of(context);
    final GoRouter router = GoRouter.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      const uuid = Uuid();
      final String bookId = uuid.v4();
      final fileService = ref.read(fileServiceProvider);
      final repository = ref.read(bookRepositoryProvider);
      final String folderPath = await fileService.createBookFolder(
        _nameController.text.trim(),
        bookId,
      );
      final String filename = p.basename(_pdfPath!);
      final String copiedPdf = await fileService.copyPdfToFolder(
        sourcePath: _pdfPath!,
        folderPath: folderPath,
        originalFilename: filename,
      );

      int totalPages = 0;
      String? coverPath;
      try {
        totalPages = await fileService.getPageCount(copiedPdf);
        coverPath = await fileService.generateCover(
          pdfPath: copiedPdf,
          folderPath: folderPath,
        );
      } catch (_) {}

      await OcrJsonManager().initialize(
        filePath: await fileService.getOcrJsonPath(p.basename(folderPath)),
        bookId: bookId,
      );
      await CleanJsonManager().initialize(
        filePath: await fileService.getCleanJsonPath(p.basename(folderPath)),
        bookId: bookId,
      );

      await repository.insertBook(
        BooksCompanion.insert(
          id: bookId,
          name: _nameController.text.trim(),
          author: Value<String>(_authorController.text.trim()),
          folderName: p.basename(folderPath),
          pdfFilename: filename,
          coverPath: Value<String?>(coverPath),
          totalPages: Value<int>(totalPages),
          languageCode: Value<String>(_languageCode),
          fileSize: Value<int>(await File(copiedPdf).length()),
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      ref.read(pipelineProvider.notifier).startPipeline(bookId);

      if (mounted) {
        navigator.pop();
        router.go(AppRoutes.processing(bookId));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
