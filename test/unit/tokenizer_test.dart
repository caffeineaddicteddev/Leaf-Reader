import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/domain/models/ocr_page.dart';
import 'package:leaf_flutter/services/pipeline/tokenizer.dart';

void main() {
  const tokenizer = Tokenizer();

  test('handles Bengali text across page boundary', () {
    final result = tokenizer.nextChunk(
      pages: const <OcrPage>[
        OcrPage(page: 1, text: 'এটি একটি অসম্পূর্ণ বাক্য', processedAt: 'now'),
        OcrPage(
          page: 2,
          text: ' যা এখানে শেষ হলো। এরপর আরেকটি।',
          processedAt: 'now',
        ),
      ],
      cursor: const TokenizerCursor(pageIndex: 0, charOffset: 0),
    );

    expect(result, isNotNull);
    expect(result!.chunk, contains('শেষ হলো।'));
    expect(result.sourcePages, equals(<int>[1, 2]));
  });

  test('handles English full stops', () {
    final result = tokenizer.nextChunk(
      pages: const <OcrPage>[
        OcrPage(
          page: 1,
          text: 'First sentence. Second sentence.',
          processedAt: 'now',
        ),
      ],
      cursor: const TokenizerCursor(pageIndex: 0, charOffset: 0),
    );

    expect(result, isNotNull);
    expect(result!.chunk, 'First sentence. Second sentence.');
  });

  test('skips empty OCR pages', () {
    final result = tokenizer.nextChunk(
      pages: const <OcrPage>[
        OcrPage(page: 1, text: '', processedAt: 'now'),
        OcrPage(page: 2, text: 'Valid page content.', processedAt: 'now'),
      ],
      cursor: const TokenizerCursor(pageIndex: 0, charOffset: 0),
    );

    expect(result, isNotNull);
    expect(result!.sourcePages, equals(<int>[2]));
  });

  test('returns last page without terminator', () {
    final result = tokenizer.nextChunk(
      pages: const <OcrPage>[
        OcrPage(
          page: 1,
          text: 'Last page without punctuation',
          processedAt: 'now',
        ),
      ],
      cursor: const TokenizerCursor(pageIndex: 0, charOffset: 0),
    );

    expect(result, isNotNull);
    expect(result!.chunk, 'Last page without punctuation');
  });

  test('handles single page book', () {
    final result = tokenizer.nextChunk(
      pages: const <OcrPage>[
        OcrPage(page: 1, text: 'One page only.', processedAt: 'now'),
      ],
      cursor: const TokenizerCursor(pageIndex: 0, charOffset: 0),
    );

    expect(result, isNotNull);
    expect(result!.nextCursor.pageIndex, 1);
  });
}
