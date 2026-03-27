# Leaf — Flutter Implementation Plan
> For AI coding agents (Codex, Claude, Cursor, etc.)
> Do not skip sections. Follow phases in order. Each phase must be complete and tested before moving to the next.

---

## 0. Project Overview

Leaf is a PDF-to-text pipeline app with a Google Docs-style reader UI.

**What it does:**
1. User imports a PDF
2. App renders each page at 300 DPI using a native platform plugin
3. Each rendered page is OCR'd — Bengali/unsupported scripts via Tesseract4Android (Android) / libtesseract (iOS), all other scripts via ML Kit Text Recognition
4. Raw OCR text is appended page-by-page into `bookname_ocr.json`
5. OCR text is tokenized (sentence-boundary aware, dari rule for Bengali) and sent to Google AI Studio for cleanup
6. Cleaned text is appended page-by-page into `bookname_clean.json`
7. User reads from `_clean.json` in a Google Docs-style scrollable reader UI
8. The first page of cleaned text is available to the reader before the full book finishes processing

**What it is NOT:**
- Not a PDF viewer — the PDF is never shown to the user
- Not a web app — Flutter only, no Capacitor, no WebView
- Not an offline AI tool — Google AI Studio (Gemini + Gemma) requires internet for the cleanup step

---

## 1. Tech Stack

| Concern | Technology |
|---|---|
| Framework | Flutter 3.x (stable channel) |
| Language | Dart (strict null safety, no dynamic types) |
| State management | Riverpod 2.x (AsyncNotifier + StateNotifier) |
| Navigation | go_router |
| Local database | drift (SQLite ORM, type-safe) |
| JSON file I/O | dart:io + dart:convert |
| PDF rendering | Custom platform plugin (MethodChannel) |
| OCR — Bengali + unsupported scripts | Custom platform plugin → Tesseract4Android (Android) / SwiftyTesseract (iOS) |
| OCR — All other scripts | Custom platform plugin → ML Kit Text Recognition |
| HTTP client | dio (for Google AI Studio REST calls) |
| File picker | file_picker |
| Background tasks | flutter_isolate or compute() for CPU work |
| Fonts | Include Kalpurush (Bengali) and SolaimanLipi in assets |
| Dependency injection | riverpod (providers as DI) |

---

## 2. Repository Structure

```
leaf/
├── android/
│   └── app/src/main/
│       ├── kotlin/com/spark/leaf/
│       │   ├── LeafPlugin.kt              # Combined PDF render + OCR plugin
│       │   └── MainActivity.kt
│       └── assets/
│           └── tessdata/
│               ├── ben.traineddata        # Bundled — Bengali
│               └── eng.traineddata        # Bundled — English
├── ios/
│   └── Runner/
│       ├── LeafPlugin.swift               # iOS equivalent
│       └── tessdata/                      # Same bundled files
├── lib/
│   ├── main.dart
│   ├── app.dart                           # Root widget, router setup
│   ├── core/
│   │   ├── constants.dart                 # API endpoints, file paths, magic numbers
│   │   ├── errors.dart                    # AppException sealed class
│   │   └── extensions.dart                # String, List, DateTime extensions
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart          # Drift database definition
│   │   │   ├── app_database.g.dart        # Generated
│   │   │   ├── tables/
│   │   │   │   ├── books_table.dart
│   │   │   │   ├── settings_table.dart
│   │   │   │   └── processing_queue_table.dart
│   │   │   └── daos/
│   │   │       ├── books_dao.dart
│   │   │       └── settings_dao.dart
│   │   ├── json/
│   │   │   ├── ocr_json_manager.dart      # Read/write _ocr.json
│   │   │   └── clean_json_manager.dart    # Read/write _clean.json
│   │   └── repositories/
│   │       ├── book_repository.dart
│   │       └── settings_repository.dart
│   ├── domain/
│   │   ├── models/
│   │   │   ├── book.dart                  # Pure Dart model
│   │   │   ├── ocr_page.dart
│   │   │   ├── clean_page.dart
│   │   │   ├── ocr_language.dart
│   │   │   └── processing_status.dart
│   │   └── language_registry.dart         # Single source of truth for languages
│   ├── services/
│   │   ├── platform/
│   │   │   └── leaf_platform_channel.dart # MethodChannel wrapper
│   │   ├── ocr/
│   │   │   ├── ocr_router.dart            # Routes to ML Kit or Tesseract
│   │   │   ├── mlkit_installer.dart       # On-demand ML Kit package download
│   │   │   └── tesseract_downloader.dart  # On-demand .traineddata download
│   │   ├── pipeline/
│   │   │   ├── ocr_orchestrator.dart      # Sequential page queue
│   │   │   ├── tokenizer.dart             # Sentence boundary splitter
│   │   │   ├── promptizer.dart            # Prompt builder, language-aware
│   │   │   └── ai_client.dart             # Gemini + Gemma REST calls
│   │   └── file_service.dart              # Copy PDF, manage book folders
│   ├── providers/
│   │   ├── database_provider.dart
│   │   ├── book_providers.dart
│   │   ├── settings_provider.dart
│   │   ├── pipeline_provider.dart
│   │   └── reader_provider.dart
│   └── ui/
│       ├── router.dart
│       ├── theme/
│       │   ├── app_theme.dart
│       │   └── text_styles.dart
│       ├── widgets/
│       │   ├── book_card.dart
│       │   ├── shimmer_block.dart
│       │   ├── progress_ring.dart
│       │   └── language_dropdown.dart
│       └── screens/
│           ├── library/
│           │   ├── library_screen.dart
│           │   └── library_notifier.dart
│           ├── create_book/
│           │   ├── create_book_sheet.dart
│           │   └── create_book_notifier.dart
│           ├── processing/
│           │   ├── processing_screen.dart
│           │   └── processing_notifier.dart
│           ├── reader/
│           │   ├── reader_screen.dart
│           │   └── reader_notifier.dart
│           └── settings/
│               ├── settings_screen.dart
│               └── settings_notifier.dart
├── test/
│   ├── unit/
│   │   ├── tokenizer_test.dart
│   │   ├── promptizer_test.dart
│   │   └── language_registry_test.dart
│   └── widget/
│       ├── library_screen_test.dart
│       └── reader_screen_test.dart
└── pubspec.yaml
```

---

## 3. pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State + navigation
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^13.0.0

  # Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # HTTP
  dio: ^5.4.0

  # File handling
  file_picker: ^8.0.0

  # JSON
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # Utils
  uuid: ^4.3.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  drift_dev: ^2.18.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.8.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.0
```

---

## 4. Platform Plugin Specification

This is the most critical part. The Flutter plugin uses a `MethodChannel` named `com.spark.leaf/native`. Both Android (Kotlin) and iOS (Swift) must implement every method identically.

### 4.1 Channel Methods

The Dart side calls these methods. Both platforms must handle all of them.

```
Method: initTesseract
  Arguments: none
  Returns: void
  Behavior:
    - Copy ben.traineddata and eng.traineddata from app assets to filesDir/tessdata/
    - Initialize a single TessBaseAPI instance with "ben+eng"
    - Keep the instance alive for the app lifetime — do NOT init per page
    - This is called once at app startup from main.dart

Method: destroyTesseract
  Arguments: none
  Returns: void
  Behavior:
    - Recycle/release the TessBaseAPI instance
    - Called only when app is terminating or all books are done

Method: getPageCount
  Arguments: { "pdfPath": String }
  Returns: { "count": int }
  Behavior:
    - Open the PDF at pdfPath
    - Return total page count
    - Do not leave the PDF renderer open

Method: renderPage
  Arguments: { "pdfPath": String, "pageNum": int (1-based), "dpi": int }
  Returns: { "imagePath": String }
  Behavior:
    - Open PDF, render the given page at (dpi / 72) scale factor
    - Output must be ARGB_8888 / full color
    - Save rendered bitmap as PNG to app cache directory
    - Filename format: leaf_p{pageNum}_{bookId}.png
    - Return absolute path to the saved PNG
    - Recycle the bitmap after saving
    - Run on a background thread — never block the main/UI thread

Method: recognizeWithTesseract
  Arguments: { "imagePath": String, "tessCode": String }
  Returns: { "text": String }
  Behavior:
    - Load bitmap from imagePath
    - Call the shared TessBaseAPI instance (do NOT create a new one per call)
    - setImage() then get utF8Text
    - Delete the PNG file after reading (cache cleanup)
    - Return recognized text
    - Run on background thread

Method: recognizeWithMlKit
  Arguments: { "imagePath": String, "script": String }
    script values: "latin", "devanagari", "chinese", "japanese", "korean"
  Returns: { "text": String }
  Behavior:
    - Load bitmap from imagePath
    - Select the correct TextRecognizer based on script value
    - Process image, concatenate all TextBlock.text with newlines
    - Delete the PNG file after reading
    - Return recognized text
    - Run on background thread

Method: ensureMlKitPackage
  Arguments: { "script": String }
  Returns: { "status": String } — "ready" | "downloading" | "failed"
  Behavior:
    - Check if the ML Kit on-demand package for that script is installed
    - If not, trigger download via ModuleInstallClient (Android) or equivalent
    - This is fire-and-forget — the caller polls or awaits as needed

Method: ensureTessData
  Arguments: { "tessCode": String }
  Returns: { "alreadyPresent": bool }
  Behavior:
    - Check if tessdata/{tessCode}.traineddata exists in filesDir
    - If yes, return { "alreadyPresent": true }
    - If no, return { "alreadyPresent": false }
    - Actual download is handled on the Dart side via dio (not native)
    - The native side only needs to confirm presence
```

### 4.2 Android Implementation Notes

- Use `CoroutineScope(Dispatchers.IO)` for all blocking work
- `PdfRenderer` is the renderer — Android API 21+, no third-party needed
- Scale factor = `dpi / 72f`
- Cache PNG files in `context.cacheDir`
- tessdata files live in `context.filesDir/tessdata/`
- Use `Tesseract4Android` version `4.8.0` from `cz.adaptech.tesseract4android`
- Keep ONE `TessBaseAPI` instance as a class field, initialized in `initTesseract`
- ML Kit packages: `com.google.mlkit:text-recognition:16.0.0` (Latin/base), plus Devanagari, Chinese, Japanese, Korean variants
- `largeHeap="true"` in AndroidManifest.xml — bitmap at 300 DPI is ~34MB per page

### 4.3 iOS Implementation Notes

- Use `PDFKit` (`CGPDFDocument` + `CGPDFPage`) for rendering
- Use `SwiftyTesseract` (Swift Package Manager) for Tesseract OCR
- Use `MLKitTextRecognition` pods for ML Kit
- Cache PNG files in `NSTemporaryDirectory()`
- tessdata files live in the app's Documents directory
- Run all blocking work via `DispatchQueue.global(qos: .userInitiated).async`
- The TessBaseAPI equivalent in SwiftyTesseract is `SwiftyTesseract` — keep a single instance

---

## 5. Database Schema (Drift)

### 5.1 Tables

**books**
```
id            TEXT PRIMARY KEY        — UUID v4
name          TEXT NOT NULL
author        TEXT DEFAULT ''
folder_name   TEXT NOT NULL UNIQUE    — format: bookname_uuidv4
pdf_filename  TEXT NOT NULL           — original filename
cover_path    TEXT NULLABLE           — path to first-page PNG (low-res, for card)
total_pages   INTEGER DEFAULT 0
ocr_progress  INTEGER DEFAULT 0       — pages OCR'd so far
ai_progress   INTEGER DEFAULT 0       — pages AI-cleaned so far
language_code TEXT DEFAULT 'ben'      — from LanguageRegistry
status        TEXT DEFAULT 'pending'  — pending | processing | ready | error
file_size     INTEGER DEFAULT 0       — bytes
created_at    TEXT                    — ISO8601
updated_at    TEXT                    — ISO8601
```

**settings**
```
key           TEXT PRIMARY KEY
value         TEXT NOT NULL

Default rows:
  ai_api_key          → ''
  gemini_model        → 'gemini-2.5-flash'
  gemma_model         → 'gemma-3-27b-it'
  vision_api_key      → ''        (reserved, not used in v1)
  theme               → 'light'
  library_path        → ''        (set at runtime to getApplicationDocumentsDirectory)
```

**processing_queue**
```
id            TEXT PRIMARY KEY
book_id       TEXT NOT NULL REFERENCES books(id) ON DELETE CASCADE
current_page  INTEGER DEFAULT 0
phase         TEXT DEFAULT 'ocr'     — ocr | ai_gemini | ai_gemma
status        TEXT DEFAULT 'queued'  — queued | running | paused | done | error
created_at    TEXT
```

### 5.2 Drift DAOs

**BooksDao must expose:**
- `watchAllBooks()` — Stream<List<Book>> (for library screen reactivity)
- `getBook(id)` — Future<Book?>
- `insertBook(book)` — Future<void>
- `updateBook(book)` — Future<void>
- `deleteBook(id)` — Future<void> (also deletes folder from filesystem)
- `updateProgress(id, ocrProgress, aiProgress, status)` — Future<void>

**SettingsDao must expose:**
- `getValue(key)` — Future<String?>
- `setValue(key, value)` — Future<void>
- `watchValue(key)` — Stream<String?> (for reactive settings)

---

## 6. Domain Models

### 6.1 OcrLanguage

```
OcrLanguage {
  displayName: String        — shown in dropdown, e.g. "Bengali"
  code: String               — internal identifier, e.g. "ben"
  engine: OcrEngine          — OcrEngine.mlkit | OcrEngine.tesseract
  mlkitScript: String?       — "latin" | "devanagari" | "chinese" | "japanese" | "korean"
                               null if engine == tesseract
  mlkitNeedsDownload: bool   — false for latin (base), true for others
  tessCode: String?          — tessdata filename prefix, null if engine == mlkit
  bundled: bool              — true only for "ben" and "eng"
}
```

### 6.2 LanguageRegistry

Single const list. Sorted alphabetically by displayName for the dropdown.
Engine assignment rules:
- If ML Kit supports the script → use ML Kit
- If ML Kit does not support the script → use Tesseract
- Never duplicate a language in both engines
- English is ML Kit (Latin base, always available)
- Bengali is Tesseract (bundled, always available offline)

**Languages to include (exactly these 22):**

| Display Name | Code | Engine | Notes |
|---|---|---|---|
| Arabic | ara | Tesseract | Download on demand |
| Bengali | ben | Tesseract | Bundled in APK |
| Burmese | mya | Tesseract | Download on demand |
| Chinese (Simplified) | chi_sim | ML Kit | On-demand package |
| Chinese (Traditional) | chi_tra | ML Kit | Same package as Simplified |
| English | eng | ML Kit | Latin base, always ready |
| French | fra | ML Kit | Latin base |
| German | deu | ML Kit | Latin base |
| Gujarati | guj | Tesseract | Download on demand |
| Hindi | hin | ML Kit | Devanagari on-demand package |
| Italian | ita | ML Kit | Latin base |
| Japanese | jpn | ML Kit | On-demand package |
| Kannada | kan | Tesseract | Download on demand |
| Korean | kor | ML Kit | On-demand package |
| Malayalam | mal | Tesseract | Download on demand |
| Marathi | mar | ML Kit | Devanagari on-demand package |
| Portuguese | por | ML Kit | Latin base |
| Punjabi | pan | Tesseract | Download on demand |
| Russian | rus | ML Kit | Latin base (Cyrillic included) |
| Spanish | spa | ML Kit | Latin base |
| Tamil | tam | Tesseract | Download on demand |
| Telugu | tel | Tesseract | Download on demand |
| Thai | tha | Tesseract | Download on demand |

### 6.3 OcrPage

```
OcrPage {
  page: int
  text: String
  processedAt: String    — ISO8601
}
```

### 6.4 CleanPage

```
CleanPage {
  page: int
  text: String
  sourcePages: List<int>    — which OCR pages contributed to this chunk
  modelUsed: String         — e.g. "gemini-2.5-flash"
  processedAt: String
}
```

### 6.5 ProcessingStatus (for UI)

```
ProcessingStatus {
  phase: ProcessingPhase      — idle | downloadingLanguage | ocr | aiCleanup | done | error
  currentPage: int
  totalPages: int
  downloadProgress: String?   — e.g. "Downloading Bengali data... 45%"
  errorMessage: String?
}
```

---

## 7. JSON File Management

### 7.1 File Locations

All book data lives inside the app's documents directory:

```
{documentsDir}/LeafLibrary/{folder_name}/
  ├── {pdf_filename}              — copied PDF (original, untouched)
  ├── {bookname}_ocr.json         — raw OCR output
  ├── {bookname}_clean.json       — AI-cleaned output
  └── cover.png                   — low-res first page thumbnail (for book card)
```

### 7.2 OcrJsonManager

Must support:
- `initFile(bookId)` — create the file with empty pages array if not exists
- `appendPage(bookId, page, text)` — read file, add new page entry, write back
- `readPages(bookId)` — return List<OcrPage>
- `getPage(bookId, pageIndex)` — return single OcrPage by 0-based index
- `pageCount(bookId)` — how many pages have been written so far

**Important:** JSON files are appended incrementally. Do NOT hold the entire file in memory during processing. Read → append → write on each page. Use a Mutex/Lock to prevent concurrent writes since OCR and AI pipelines run concurrently.

### 7.3 CleanJsonManager

Same interface as OcrJsonManager but for `_clean.json` with CleanPage entries.

Must additionally support:
- `watchPages(bookId)` — Stream<List<CleanPage>> for reactive reader UI updates

Implement `watchPages` using a periodic poll (every 2 seconds) on the file, comparing page count to previous count and emitting when new pages appear. Do NOT use file system watchers — they are unreliable on Android.

---

## 8. OCR Pipeline

### 8.1 OcrOrchestrator

This is the heart of the app. It must:

1. Accept a `bookId` and run the full pipeline for that book
2. Be cancellable — expose a `cancel()` method that stops processing cleanly
3. Update the database progress after every page
4. Never process two books simultaneously (enforce via a lock or queue)
5. Be implemented as a long-running async task, NOT blocking the UI isolate

**Sequential processing loop (pseudocode):**

```
function startPipeline(book):
  language = LanguageRegistry.byCode(book.languageCode)

  // Step 0: Prepare language resources
  await prepareLanguage(language)

  // Step 1: Get page count
  pageCount = await platformChannel.getPageCount(book.pdfPath)
  await db.updateBook(book.id, totalPages: pageCount)

  // Step 2: Generate low-res cover for book card (page 1, 72 DPI)
  await generateCover(book)

  // Step 3: Sequential OCR loop
  for pageNum in 1..pageCount:
    if cancelled: break

    // Render at 300 DPI
    imagePath = await platformChannel.renderPage(book.pdfPath, pageNum, 300)

    // OCR
    text = await ocrRouter.recognize(imagePath, language)

    // Persist
    await ocrJsonManager.appendPage(book.id, pageNum, text)
    await db.updateOcrProgress(book.id, pageNum)

    // After page 1 OCR is done, immediately start AI cleanup in parallel
    if pageNum == 1:
      startAiCleanupInBackground(book)    // do NOT await — runs concurrently

    // Yield to event loop between pages
    await Future.delayed(Duration.zero)

  // Step 4: Mark OCR complete
  await db.updateStatus(book.id, status: 'ready')
```

**Key rules:**
- `renderPage` and `recognize` are called sequentially — never in parallel
- The AI cleanup runs concurrently with OCR but never concurrently with itself
- If OCR fails on a page, log the error, write empty string for that page, continue
- `Future.delayed(Duration.zero)` between pages yields control — required to keep UI responsive

### 8.2 AI Cleanup Trigger Logic

The AI cleanup runs in a separate async loop, concurrently with OCR:

```
function startAiCleanupInBackground(book):
  cursor = TokenizerCursor(pageIndex: 0, charOffset: 0)
  pagesProcessedByAi = 0

  loop:
    if cancelled: break

    // Wait until at least one more OCR page is available beyond cursor
    ocrPageCount = await ocrJsonManager.pageCount(book.id)
    if cursor.pageIndex >= ocrPageCount:
      await Future.delayed(Duration(seconds: 2))
      continue

    // Get next sentence-bounded chunk
    result = await tokenizer.nextChunk(book.id, cursor)
    if result == null: break

    // Determine which model to use
    model = pagesProcessedByAi < 10 ? 'gemini' : 'gemma'

    // Call AI
    cleaned = await aiClient.callWithFallback(model, result.chunk, book.languageCode)

    // Persist
    await cleanJsonManager.appendPage(book.id, pagesProcessedByAi + 1, cleaned, result.sourcePages, modelUsed)

    cursor = result.nextCursor
    pagesProcessedByAi++

    // Check if OCR is fully done and we've caught up
    if ocrDone && cursor.pageIndex >= totalOcrPages: break
```

**The 70% rule for triggering next AI page in reader:**
- Track scroll position in the reader
- When user has scrolled past 70% of the current last clean page, trigger the next cleanup call if it hasn't run yet
- This is handled in ReaderNotifier, not in the pipeline

### 8.3 OcrRouter

```
function recognize(imagePath, language):
  if language.engine == OcrEngine.tesseract:
    return await platformChannel.recognizeWithTesseract(imagePath, language.tessCode)
  else:
    return await platformChannel.recognizeWithMlKit(imagePath, language.mlkitScript)
```

### 8.4 Language Preparation

```
function prepareLanguage(language):
  if language.engine == OcrEngine.tesseract:
    if NOT language.bundled:
      if NOT await platformChannel.ensureTessData(language.tessCode):
        await tesseractDownloader.download(language.tessCode, onProgress)
  else (ML Kit):
    if language.mlkitNeedsDownload:
      await mlkitInstaller.ensurePackage(language.mlkitScript, onProgress)
```

**Tesseract downloader (Dart side, using dio):**
- Download URL: `https://github.com/tesseract-ocr/tessdata_fast/raw/main/{tessCode}.traineddata`
- Save to a temp file first, then move to `filesDir/tessdata/{tessCode}.traineddata`
- Report progress via a callback that updates ProcessingStatus
- If download fails, surface error to UI — do NOT silently continue

---

## 9. Tokenizer

### 9.1 Specification

The tokenizer's job is to ensure no broken sentence is ever sent to the AI. It reads from `_ocr.json` and produces sentence-bounded chunks.

**Input:** `bookId`, `TokenizerCursor { pageIndex: int, charOffset: int }`
**Output:** `TokenizerResult { chunk: String, nextCursor: TokenizerCursor, sourcePages: List<int> }` or null if no more content

**Algorithm:**

```
1. Load page blobs from _ocr.json starting at cursor.pageIndex
2. Concatenate text: from cursor.charOffset of startPage, then full text of up to 2 more pages
3. Scan the combined string backwards from the end for the last sentence terminator:
     Bengali dari:          '।'
     Full stop + space:     '. '
     Full stop + newline:   '.\n'
     Question mark + space: '? '
     Exclamation + space:   '! '
     Question + newline:    '?\n'
     Exclamation + newline: '!\n'
4. The chunk = combined[0 .. lastTerminatorIndex + terminatorLength].trim()
5. If no terminator found within 2 pages: force-break at last whitespace
6. Walk through page blobs to calculate nextCursor position
7. Track which page indices contributed to the chunk → sourcePages
8. Return { chunk, nextCursor, sourcePages }
```

**Edge cases to handle:**
- Page blob is empty (OCR failed for that page) → skip it, advance cursor
- First page has no terminator at all → force-break at end of page
- Last page of book → return remaining text even if no terminator
- charOffset > page text length → advance to next page, reset charOffset to 0

### 9.2 TokenizerCursor

```
TokenizerCursor {
  pageIndex: int      — 0-based index into the pages array in _ocr.json
  charOffset: int     — character position within that page's text
}
```

---

## 10. Promptizer

### 10.1 Gemini Prompt (pages 1-10, language-aware)

Build this string dynamically with the language display name interpolated:

```
You are a text restoration assistant. You receive OCR-scanned text from a book.
The text may contain prefaces, tables of contents, forewords, publisher info,
or introductory material.

Your tasks:
1. Strip any preface, table of contents, foreword, publisher info, or non-content
   metadata from the output.
2. Output ONLY the actual book content (narrative, chapters, body text).
3. Correct OCR errors: fix misrecognized characters, broken words, noise artifacts.
4. Do NOT rephrase, summarize, or alter the meaning of any sentence.
5. Preserve the original language ({languageDisplayName}) exactly as written.
6. Maintain paragraph structure and natural line breaks.
7. If the entire input is preface/metadata with no body content, output exactly: [NO_CONTENT]

Output the corrected text only, with no commentary or preamble.

OCR Text:
{ocrText}
```

### 10.2 Gemma Prompt (pages 11+)

```
You are a text correction assistant. You receive OCR-scanned text from a book.

Your tasks:
1. Correct OCR errors: fix misrecognized characters, broken words, noise artifacts.
2. Do NOT rephrase, summarize, or alter the meaning of any sentence.
3. Preserve the original language ({languageDisplayName}) exactly as written.
4. Maintain paragraph structure and natural line breaks.
5. Output the corrected text only, with no commentary or preamble.

OCR Text:
{ocrText}
```

---

## 11. AI Client

### 11.1 Endpoint

```
POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}

Body:
{
  "contents": [{ "parts": [{ "text": "{fullPrompt}" }] }],
  "generationConfig": { "temperature": 0.1, "maxOutputTokens": 8192 }
}

Response path: data['candidates'][0]['content']['parts'][0]['text']
```

### 11.2 Model Routing

```
Phase 'gemini' (pages 1-10):
  Primary:  gemini-2.5-flash
  On 429 or 5xx: wait 30 seconds, retry same model
  On persistent failure after 3 retries: surface error, pause pipeline

Phase 'gemma' (pages 11+):
  Primary:  gemma-3-27b-it
  Fallback: gemma-3-12b-it
  Fallback: gemma-3-4b-it
  On all failing: wait 30 seconds, retry gemma-3-27b-it
```

### 11.3 Error Handling Rules

- Network timeout: retry after 5 seconds, max 3 attempts
- 429 rate limit: wait 30 seconds, retry
- 500/503: retry after 10 seconds
- 400 bad request: do NOT retry — log and skip page, write empty string to clean.json
- If API key is empty: surface SettingsError to UI immediately, pause pipeline

---

## 12. UI Screens

### 12.1 Library Screen

**Route:** `/` (home)

**Layout:**
- AppBar with app name "Leaf" and a `+` icon button
- Grid of BookCards (2 columns on phone, 3 on tablet)
- Empty state when no books exist
- Search bar that filters by name/author using Drift FTS or simple string contains

**BookCard:**
- Cover image (cover.png from book folder) — if not yet generated, show placeholder
- Book name (truncated to 2 lines)
- Author name (1 line, muted)
- Progress indicator ring showing (aiProgress / totalPages) as percentage
- Status chip: "Processing" | "Ready" | "Error"
- Long press → context menu with "Edit" and "Delete"
- Tap → navigate to ReaderScreen if status is ready, ProcessingScreen if processing

**Reactivity:** LibraryScreen must use `watchAllBooks()` stream — updates automatically when any book changes

### 12.2 Create Book Bottom Sheet

**Triggered by:** `+` button on Library screen

**Fields:**
- Name (TextFormField, required)
- Author (TextFormField, optional)
- Language (LanguageDropdown — shows all 22 languages alphabetically, no engine details)
- PDF Source (tap to open file_picker, shows selected filename after pick)

**On create:**
1. Validate name and PDF are provided
2. Generate UUID v4
3. Create folder: `{documentsDir}/LeafLibrary/{bookname}_{uuid}/`
4. Copy selected PDF into folder
5. Insert book record into database with status 'pending'
6. Close sheet
7. Navigate to ProcessingScreen
8. Start OcrOrchestrator for this book

**Edit sheet (same UI, different title):**
- Only name and author are editable
- Language cannot be changed after creation
- PDF cannot be changed after creation

### 12.3 Processing Screen

**Route:** `/processing/:bookId`

**Layout:**
- Book name and author at top
- Large circular progress indicator: OCR progress (outer ring) + AI progress (inner ring)
- Status text: current phase description
- Download progress bar (visible only when downloading language data)
- Page counter: "Page X of Y"
- Cancel button — cancels pipeline, resets book to 'pending' status, deletes partial JSON files

**Reactive:** ProcessingNotifier exposes `Stream<ProcessingStatus>` — screen rebuilds on each status update

**Auto-navigation:** When AI has cleaned at least 1 page, show "Open Book" button. This navigates to ReaderScreen while processing continues in background.

### 12.4 Reader Screen

**Route:** `/reader/:bookId`

**Layout:**
- Minimal AppBar with book name and back button
- Scrollable text body (ListView.builder over CleanPage list)
- Each page rendered as a Text widget with appropriate font
- Bengali text: use Kalpurush font family
- Latin/other text: use system serif or a bundled serif font
- Shimmer placeholder blocks for pages not yet cleaned
- Font size adjustable via floating action button (small/medium/large toggle)

**Reactivity:**
- `watchPages(bookId)` stream drives the ListView
- When new pages arrive (stream emits), ListView extends — user position is preserved
- 70% scroll trigger: when user scrolls past 70% of the last available page, notify ReaderNotifier which triggers next AI cleanup if idle

**Reading progress tracking:**
- Track scroll position as (topVisiblePage / totalCleanPages)
- Save to database on pause/dispose
- Restore scroll position on re-open

### 12.5 Settings Screen

**Route:** `/settings`

**Sections:**

*AI Configuration*
- Google AI Studio API Key (obscured text field, show/hide toggle)
- Gemini Model (dropdown: gemini-2.5-flash, gemini-2.0-flash, gemini-1.5-flash — plus free text field)
- Gemma Model (dropdown: gemma-3-27b-it, gemma-3-12b-it, gemma-3-4b-it — plus free text field)

*Appearance*
- Theme toggle: Light / Dark / System

*Storage*
- Library location (read-only display of current path)
- Total storage used (calculated from all book folders)
- "Clear cache" button (deletes temp PNG files from cache dir)

*About*
- App version
- Link to tessdata_fast repo (for attribution)

---

## 13. State Management (Riverpod)

### 13.1 Provider Structure

```
databaseProvider          — AppDatabase singleton
bookRepositoryProvider    — BookRepository (depends on databaseProvider)
settingsRepositoryProvider — SettingsRepository (depends on databaseProvider)

// Library
booksProvider             — StreamProvider<List<Book>> watching all books
                            Uses bookRepository.watchAllBooks()

// Pipeline
pipelineProvider          — StateNotifierProvider<PipelineNotifier, PipelineState>
                            One notifier manages the active pipeline
                            Exposes: startPipeline(book), cancelPipeline(), processingStatus

// Reader
cleanPagesProvider(bookId) — StreamProvider<List<CleanPage>>
                             Wraps cleanJsonManager.watchPages(bookId)
readerProgressProvider    — StateProvider<Map<String, double>>
                             bookId → scroll progress (0.0 to 1.0)

// Settings
settingsProvider          — AsyncNotifierProvider<SettingsNotifier, AppSettings>
```

### 13.2 PipelineNotifier Rules

- Only one book can be processing at a time
- If app is killed mid-processing, on restart: check database for any book with status 'processing', resume from `ocr_progress` page
- Resume means: skip pages already in `_ocr.json`, restart OCR from `ocr_progress + 1`
- AI cleanup resume: check `_clean.json` page count, resume tokenizer cursor from there

---

## 14. Theme

### 14.1 Typography

- Primary font: system default (Roboto on Android, SF Pro on iOS)
- Bengali text in reader: Kalpurush (bundle in assets/fonts/)
- Reader body text size: 16sp default, adjustable to 14sp / 18sp / 20sp
- Line height: 1.7 × font size for all reader text

### 14.2 Colors

Define a full MaterialTheme with both light and dark variants:

```
Light theme:
  primary:        #1A1A2E  (deep navy)
  surface:        #FFFFFF
  background:     #F8F7F4  (warm off-white — like paper)
  onBackground:   #2C2C2A
  secondary:      #4A7B5E  (muted green — leaf reference)

Dark theme:
  primary:        #E8E6D9
  surface:        #1C1C1A
  background:     #141413
  onBackground:   #E8E6D9
  secondary:      #6AAF88
```

### 14.3 Reader Specific Styles

The reader screen should feel like reading a real book:
- Background: warm paper color in light mode (#F8F7F4), dark sepia in dark mode (#1C1A16)
- Text color: near-black in light (#2C2C2A), warm off-white in dark (#E8E6D9)
- No hard white backgrounds in the reader
- Generous horizontal padding: 24dp on each side
- Page breaks: subtle divider line between CleanPage blocks

---

## 15. File Service

### FileService responsibilities:

```
createBookFolder(bookName, uuid):
  — Create {documentsDir}/LeafLibrary/{bookname}_{uuid}/
  — Return folder path

copyPdfToFolder(sourcePath, folderPath, originalFilename):
  — Copy PDF file into the book folder
  — Return new PDF path inside the folder

deleteBookFolder(folderPath):
  — Recursively delete the entire book folder
  — Called on book deletion

generateCover(bookId, pdfPath, folderPath):
  — Call platformChannel.renderPage(pdfPath, 1, 72)  ← low DPI for thumbnail
  — Copy the result to {folderPath}/cover.png
  — Return cover.png path

getLibrarySize():
  — Walk all book folders
  — Sum file sizes
  — Return total bytes

clearCache():
  — Delete all files in app cache directory matching "leaf_p*.png"
```

---

## 16. Error Handling Strategy

All errors must surface to the UI — never silently swallow exceptions.

**Define sealed class AppException:**
```
AppException
  ├── PipelineException(String message, int? pageNum)
  ├── OcrException(String message, int pageNum)
  ├── AiException(String message, String model, int? statusCode)
  ├── LanguageDownloadException(String language, String message)
  ├── FileException(String message, String? path)
  └── SettingsException(String message)  — e.g. missing API key
```

**Per-layer rules:**
- Platform channel failures → throw PipelineException, log page number
- OCR failures on a page → write empty string, increment progress, continue
- AI failures → retry per model routing rules, then throw AiException
- File I/O failures → throw FileException, show error in UI, offer retry
- Missing API key → throw SettingsException immediately, navigate to Settings

---

## 17. Implementation Phases

Follow these phases strictly. Do not start phase N+1 until phase N passes its tests.

### Phase 1 — Project scaffold
- Create Flutter project with all pubspec.yaml dependencies
- Set up folder structure exactly as specified in Section 2
- Configure go_router with all routes (screens can be empty placeholders)
- Set up Riverpod in main.dart
- Set up drift database with all tables and DAOs
- Run `flutter test` — all generated code compiles

### Phase 2 — Platform plugin (Android first)
- Implement LeafPlugin.kt with all 7 methods from Section 4.1
- Add Tesseract4Android to build.gradle
- Add ML Kit dependencies to build.gradle
- Add `android:largeHeap="true"` to AndroidManifest.xml
- Copy ben.traineddata + eng.traineddata to android/app/src/main/assets/tessdata/
- Write a simple Flutter test app that calls each method and prints the result
- Verify: render page 1 of a test PDF at 300 DPI, then OCR it with Tesseract Bengali
- Verify: render page 1 of an English PDF, then OCR it with ML Kit Latin

### Phase 3 — Data layer
- Implement OcrJsonManager with all methods including the Mutex for concurrent writes
- Implement CleanJsonManager including watchPages() polling stream
- Implement FileService
- Write unit tests for OcrJsonManager: appendPage, readPages, getPage, pageCount
- Write unit tests for FileService: createBookFolder, deleteBookFolder

### Phase 4 — Domain layer
- Implement LanguageRegistry with all 22 languages
- Implement Tokenizer with full dari rule and all edge cases
- Write unit tests for Tokenizer:
  - Bengali text ending mid-sentence across page boundary
  - English text with standard full stops
  - Empty page blob (OCR failure)
  - Last page with no terminator
  - Single-page book

### Phase 5 — Pipeline services
- Implement OcrRouter
- Implement TesseractDownloader (dio-based, with progress)
- Implement MlKitInstaller
- Implement Promptizer (both prompts, language interpolation)
- Implement AiClient with full model routing and retry logic
- Implement OcrOrchestrator with sequential loop and concurrent AI cleanup
- Write unit tests for Promptizer: verify language name is interpolated correctly
- Write unit tests for AiClient: mock dio responses, verify retry behavior

### Phase 6 — Riverpod providers
- Implement all providers from Section 13
- Implement PipelineNotifier with start, cancel, and resume logic
- Implement resume-on-restart logic (check for 'processing' books on app start)
- Wire providers to repositories and services

### Phase 7 — UI screens
- Implement Library screen with reactive book grid
- Implement Create Book bottom sheet with file picker
- Implement Edit Book bottom sheet
- Implement Processing screen with dual-ring progress and download progress
- Implement Reader screen with watchPages stream, shimmer placeholders, 70% trigger
- Implement Settings screen with all fields
- Implement BookCard with cover image, progress ring, long-press context menu

### Phase 8 — Theme and fonts
- Bundle Kalpurush font in assets/fonts/
- Define full MaterialTheme (light + dark) per Section 14
- Apply theme throughout all screens
- Apply Bengali font selectively in Reader for Bengali books

### Phase 9 — iOS plugin
- Implement LeafPlugin.swift with same 7 methods as the Android plugin
- Use PDFKit for rendering, SwiftyTesseract for OCR, MLKit pods for ML Kit
- Copy tessdata files into ios/Runner/tessdata/
- Verify same test cases as Phase 2 pass on iOS simulator

### Phase 10 — Integration testing
- Full pipeline test: import a Bengali PDF → OCR all pages → AI cleanup → read in reader
- Full pipeline test: import an English PDF → ML Kit OCR → AI cleanup → read in reader
- Cancel pipeline mid-processing → verify clean state, no partial files left behind
- Delete book → verify folder is removed, database record gone
- Settings: enter API key → verify it persists across app restarts
- Language download: select Arabic → verify traineddata downloads → OCR succeeds

---

## 18. Critical Rules for Implementing Agents

Read these before writing any code.

1. **Never block the UI isolate.** All file I/O, platform channel calls, and HTTP calls must be `await`ed inside async functions. Never use `.then()` chains where `await` works.

2. **One TessBaseAPI instance per language, kept alive for the app session.** Never create a new instance per page. Never call `init()` inside `recognizeWithTesseract()`.

3. **Always recycle/delete the rendered PNG after OCR.** The 300 DPI PNG is ~34MB. Leaving it in cache will fill storage on long books.

4. **The JSON files are the source of truth for pipeline progress, not the database.** The database tracks status and progress integers for the UI. The actual text lives in the JSON files.

5. **The Mutex on JSON file writes is non-negotiable.** Both the OCR loop and the AI loop write to different files, but the OCR loop writes `_ocr.json` frequently. If any future change ever writes to the same file from two coroutines, data corruption will occur without the Mutex.

6. **The tokenizer must never send broken sentences.** Test this with real Bengali text before marking Phase 5 complete. A broken dari mid-sentence going to the AI is a correctness bug, not a cosmetic one.

7. **Resume logic is mandatory.** Users will background the app during processing. The pipeline must resume from where it left off, not restart from page 1.

8. **API key validation happens before the pipeline starts.** If `ai_api_key` is empty string, throw SettingsException immediately and navigate user to Settings. Do not start the pipeline.

9. **`[NO_CONTENT]` handling.** If the AI returns exactly `[NO_CONTENT]` for a chunk (meaning the tokenizer sent preface/metadata), write an empty CleanPage for those source pages. Do not show `[NO_CONTENT]` string in the reader.

10. **Language cannot be changed after book creation.** The tessdata or ML Kit model is baked into the OCR pipeline run. Changing it mid-run would produce inconsistent `_ocr.json` content. Enforce this in the Edit Book sheet by making the language field read-only.
