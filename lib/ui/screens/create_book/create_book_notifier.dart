import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateBookState {
  const CreateBookState({
    this.name = '',
    this.author = '',
    this.languageCode = 'ben',
    this.pdfPath,
  });

  final String name;
  final String author;
  final String languageCode;
  final String? pdfPath;
}

class CreateBookNotifier extends StateNotifier<CreateBookState> {
  CreateBookNotifier() : super(const CreateBookState());
}
