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

class Tokenizer {
  const Tokenizer();

  static const List<String> _terminators = <String>[
    '।',
    '.',
    '. ',
    '.\n',
    '?',
    '? ',
    '?\n',
    '!',
    '! ',
    '!\n',
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
    final List<int> pageStarts = <int>[];
    final int startPageIndex = pageIndex;
    int collected = 0;
    for (
      int index = pageIndex;
      index < pages.length && collected < 3;
      index += 1
    ) {
      final String pageText = index == pageIndex
          ? pages[index].text.substring(charOffset)
          : pages[index].text;
      if (pageText.trim().isEmpty) {
        continue;
      }
      pageStarts.add(buffer.length);
      buffer.write(pageText);
      sourcePages.add(pages[index].page);
      collected += 1;
    }

    final String combined = buffer.toString();
    if (combined.trim().isEmpty) {
      return null;
    }

    int splitIndex = _findSentenceBreak(combined);
    if (splitIndex == -1 &&
        startPageIndex + sourcePages.length < pages.length) {
      splitIndex = _findWhitespaceBreak(combined);
    }
    if (splitIndex == -1) {
      splitIndex = combined.length;
    }

    final String chunk = combined.substring(0, splitIndex).trim();
    final TokenizerCursor nextCursor = _advanceCursor(
      pages: pages,
      startPageIndex: startPageIndex,
      initialOffset: charOffset,
      consumedCharacters: splitIndex,
    );

    return TokenizerResult(
      chunk: chunk,
      nextCursor: nextCursor,
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

  int _findWhitespaceBreak(String combined) {
    final int whitespace = combined.lastIndexOf(RegExp(r'\s'));
    if (whitespace == -1) {
      return -1;
    }
    return whitespace + 1;
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
