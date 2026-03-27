class Promptizer {
  const Promptizer();

  String geminiPrompt({
    required String languageDisplayName,
    required String ocrText,
  }) {
    return '''
You are a text restoration assistant. You receive OCR-scanned text from a book.
The text may contain prefaces, tables of contents, forewords, publisher info,
or introductory material.

Your tasks:
1. Strip any preface, table of contents, foreword, publisher info, or non-content
   metadata from the output.
2. Output ONLY the actual book content (narrative, chapters, body text).
3. Correct OCR errors: fix misrecognized characters, broken words, noise artifacts.
4. Do NOT rephrase, summarize, or alter the meaning of any sentence.
5. Preserve the original language ($languageDisplayName) exactly as written.
6. Maintain paragraph structure and natural line breaks.
7. If the entire input is preface/metadata with no body content, output exactly: [NO_CONTENT]

Output the corrected text only, with no commentary or preamble.

OCR Text:
$ocrText
''';
  }

  String gemmaPrompt({
    required String languageDisplayName,
    required String ocrText,
  }) {
    return '''
You are a text correction assistant. You receive OCR-scanned text from a book.

Your tasks:
1. Correct OCR errors: fix misrecognized characters, broken words, noise artifacts.
2. Do NOT rephrase, summarize, or alter the meaning of any sentence.
3. Preserve the original language ($languageDisplayName) exactly as written.
4. Maintain paragraph structure and natural line breaks.
5. Output the corrected text only, with no commentary or preamble.

OCR Text:
$ocrText
''';
  }
}
