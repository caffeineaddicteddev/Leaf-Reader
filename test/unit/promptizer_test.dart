import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/services/pipeline/promptizer.dart';

void main() {
  const promptizer = Promptizer();

  test('gemini prompt interpolates language name', () {
    final prompt = promptizer.geminiPrompt(
      languageDisplayName: 'Bengali',
      ocrText: 'sample',
    );

    expect(prompt, contains('Bengali'));
    expect(prompt, contains('sample'));
  });

  test('gemma prompt interpolates language name', () {
    final prompt = promptizer.gemmaPrompt(
      languageDisplayName: 'English',
      ocrText: 'sample',
    );

    expect(prompt, contains('English'));
    expect(prompt, contains('sample'));
  });
}
