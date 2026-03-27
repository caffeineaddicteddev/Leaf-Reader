import '../../domain/models/ocr_page.dart';

class TokenizerCursor {
  const TokenizerCursor({required this.pageIndex, required this.charOffset});

  final int pageIndex;
  final int charOffset;
}

class TokenizerResult {
  const TokenizerResult({
    required this.chunk,
    required this.nextCursor,
    required this.sourcePages,
  });

  final String chunk;
  final TokenizerCursor nextCursor;
  final List<int> sourcePages;
}

class TokenizerBoundary {
  const TokenizerBoundary({
    required this.chunk,
    required this.nextCursor,
    required this.sourcePages,
  });

  final String chunk;
  final TokenizerCursor nextCursor;
  final List<int> sourcePages;
}

class Tokenizer {
  const Tokenizer();

  static const List<String> _terminators = <String>[
    '.',
    '?',
    '!',
    '\u0964',
    '\u0965',
    '\u06d4',
    '\u061f',
    '\u3002',
    '\uff01',
    '\uff1f',
  ];

  TokenizerResult? nextChunk({
    required List<OcrPage> pages,
    required TokenizerCursor cursor,
  }) {
    int pageIndex = cursor.pageIndex;
    int charOffset = cursor.charOffset;
    while (pageIndex < pages.length) {
      final String pageText = pages[pageIndex].text;
      if (charOffset >= pageText.length || pageText.trim().isEmpty) {
        pageIndex += 1;
        charOffset = 0;
        continue;
      }
      break;
    }
    if (pageIndex >= pages.length) {
      return null;
    }

    final StringBuffer buffer = StringBuffer();
    final List<int> sourcePages = <int>[];
    for (int index = pageIndex; index < pages.length; index += 1) {
      final String pageText = index == pageIndex
          ? pages[index].text.substring(charOffset)
          : pages[index].text;
      if (pageText.trim().isEmpty) {
        continue;
      }
      buffer.write(pageText);
      sourcePages.add(pages[index].page);
      final int splitIndex = _findSentenceBreak(buffer.toString());
      if (splitIndex != -1) {
        final String chunk = buffer.toString().substring(0, splitIndex).trim();
        return TokenizerResult(
          chunk: chunk,
          nextCursor: _advanceCursor(
            pages: pages,
            startPageIndex: pageIndex,
            initialOffset: charOffset,
            consumedCharacters: splitIndex,
          ),
          sourcePages: sourcePages,
        );
      }
    }

    final String combined = buffer.toString().trim();
    if (combined.isEmpty) {
      return null;
    }

    return TokenizerResult(
      chunk: combined,
      nextCursor: TokenizerCursor(pageIndex: pages.length, charOffset: 0),
      sourcePages: sourcePages,
    );
  }

  TokenizerBoundary splitAtLastSentenceBoundary({
    required List<OcrPage> pages,
    TokenizerCursor cursor = const TokenizerCursor(pageIndex: 0, charOffset: 0),
  }) {
    int pageIndex = cursor.pageIndex;
    int charOffset = cursor.charOffset;
    while (pageIndex < pages.length) {
      final String pageText = pages[pageIndex].text;
      if (charOffset >= pageText.length || pageText.trim().isEmpty) {
        pageIndex += 1;
        charOffset = 0;
        continue;
      }
      break;
    }

    if (pageIndex >= pages.length) {
      return TokenizerBoundary(
        chunk: '',
        nextCursor: TokenizerCursor(pageIndex: pages.length, charOffset: 0),
        sourcePages: const <int>[],
      );
    }

    final StringBuffer buffer = StringBuffer();
    final List<int> sourcePages = <int>[];
    for (int index = pageIndex; index < pages.length; index += 1) {
      final String pageText = index == pageIndex
          ? pages[index].text.substring(charOffset)
          : pages[index].text;
      if (pageText.trim().isEmpty) {
        continue;
      }
      buffer.write(pageText);
      sourcePages.add(pages[index].page);
    }

    final String combined = buffer.toString();
    if (combined.trim().isEmpty) {
      return TokenizerBoundary(
        chunk: '',
        nextCursor: TokenizerCursor(pageIndex: pages.length, charOffset: 0),
        sourcePages: const <int>[],
      );
    }

    final int splitIndex = _findSentenceBreak(combined);
    if (splitIndex == -1) {
      return TokenizerBoundary(
        chunk: combined.trim(),
        nextCursor: TokenizerCursor(pageIndex: pages.length, charOffset: 0),
        sourcePages: sourcePages,
      );
    }

    return TokenizerBoundary(
      chunk: combined.substring(0, splitIndex).trim(),
      nextCursor: _advanceCursor(
        pages: pages,
        startPageIndex: pageIndex,
        initialOffset: charOffset,
        consumedCharacters: splitIndex,
      ),
      sourcePages: sourcePages,
    );
  }

  int _findSentenceBreak(String combined) {
    int bestIndex = -1;
    for (final String terminator in _terminators) {
      final int index = combined.lastIndexOf(terminator);
      if (index != -1) {
        final int candidate = index + terminator.length;
        if (candidate > bestIndex) {
          bestIndex = candidate;
        }
      }
    }
    return bestIndex;
  }

  TokenizerCursor _advanceCursor({
    required List<OcrPage> pages,
    required int startPageIndex,
    required int initialOffset,
    required int consumedCharacters,
  }) {
    int remaining = consumedCharacters;
    int pageIndex = startPageIndex;
    int offset = initialOffset;
    while (pageIndex < pages.length) {
      final String text = pages[pageIndex].text;
      final int available = (text.length - offset).clamp(0, text.length);
      if (remaining < available) {
        return TokenizerCursor(
          pageIndex: pageIndex,
          charOffset: offset + remaining,
        );
      }
      remaining -= available;
      pageIndex += 1;
      offset = 0;
      if (remaining == 0) {
        return TokenizerCursor(pageIndex: pageIndex, charOffset: 0);
      }
    }
    return TokenizerCursor(pageIndex: pages.length, charOffset: 0);
  }
}
