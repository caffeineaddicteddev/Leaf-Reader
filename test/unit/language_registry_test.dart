import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/domain/language_registry.dart';

void main() {
  test('language registry includes expected key languages', () {
    final codes = LanguageRegistry.languages
        .map((language) => language.code)
        .toSet();
    expect(codes.contains('ben'), isTrue);
    expect(codes.contains('eng'), isTrue);
    expect(codes.contains('hin'), isTrue);
    expect(codes.contains('jpn'), isTrue);
  });
}
