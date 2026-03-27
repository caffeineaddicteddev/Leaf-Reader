# Leaf

Leaf is a Flutter-based PDF-to-text reading pipeline designed for books and long-form documents. Instead of exposing a traditional PDF viewer, Leaf imports a PDF, renders each page natively, extracts text with OCR, cleans that OCR output with Google AI Studio models, and presents the result in a reader-first interface inspired by document and ebook reading surfaces.

Created by [Sajid](https://github.com/caffeineaddicteddev).

## Overview

Leaf is built around a staged processing pipeline:

1. Import a PDF into the local library.
2. Render pages natively on Android.
3. Run OCR using either Tesseract or ML Kit, depending on language/script.
4. Persist raw OCR output page-by-page to JSON.
5. Chunk OCR text with sentence-aware tokenization.
6. Send chunks to Google AI Studio for cleanup.
7. Persist cleaned output page-by-page to JSON.
8. Stream cleaned pages into a reader-oriented UI.

The app is intentionally not a PDF viewer. The PDF is treated as a source artifact for text extraction and cleanup, while the reading experience is driven by processed text.

## Current Status

This repository currently includes:

- Flutter app scaffold with Riverpod, go_router, Drift, and Material 3 theming
- Android native plugin for PDF rendering, Tesseract OCR, ML Kit OCR, and model/package checks
- Drift database schema for books, settings, and processing queue state
- JSON managers for raw OCR and cleaned page persistence
- Language registry with the planned OCR language set
- Tokenizer and prompt builder foundations
- AI client with retry handling for Google AI Studio calls
- File management for library folders, copied PDFs, and generated covers
- First-pass UI for library, create-book, processing, reader, and settings screens
- Unit tests for tokenizer, promptizer, JSON manager, file service, AI client, and language registry

Still in progress:

- Full OCR orchestrator loop
- Resume-on-restart pipeline behavior
- Live cleaned-page streaming into the reader
- Full settings editing and persistence UI
- End-to-end processing flow from imported PDF to readable cleaned content
- iOS implementation

## Architecture

The implementation follows a layered structure:

### UI Layer

- `lib/ui/`
- Screens, widgets, routing, and theme configuration
- Uses UI references from the local `UI/` folder for visual direction

### Provider Layer

- `lib/providers/`
- Riverpod providers for database, repositories, pipeline state, settings, and reader state

### Domain Layer

- `lib/domain/`
- Pure Dart models and language registry metadata

### Data Layer

- `lib/data/`
- Drift database tables and DAOs
- JSON persistence managers
- Repository abstractions over local storage

### Service Layer

- `lib/services/`
- Native platform channel wrapper
- File system operations
- Tokenization and AI request logic

### Native Android Layer

- `android/app/src/main/kotlin/com/spark/leaf/`
- `LeafPlugin.kt` implements:
  - `initTesseract`
  - `destroyTesseract`
  - `getPageCount`
  - `renderPage`
  - `recognizeWithTesseract`
  - `recognizeWithMlKit`
  - `ensureMlKitPackage`
  - `ensureTessData`

## Tech Stack

### Flutter and Dart

- Flutter 3.41.x
- Dart 3.11.x

### App Framework

- `flutter_riverpod`
- `go_router`
- `drift`
- `sqlite3_flutter_libs`
- `dio`
- `file_picker`
- `path_provider`
- `uuid`
- `intl`

### Android Native

- Kotlin
- Android `PdfRenderer`
- Tesseract4Android
- Google ML Kit Text Recognition
- Google Play Services Module Install APIs
- Kotlin coroutines

## Repository Structure

```text
leaf_flutter/
├── android/
│   └── app/src/main/
│       ├── assets/tessdata/
│       └── kotlin/com/spark/leaf/
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── core/
│   ├── data/
│   ├── domain/
│   ├── providers/
│   ├── services/
│   └── ui/
├── test/
│   ├── unit/
│   └── widget/
├── UI/
├── implementation_plan.md
└── pubspec.yaml
```

## Database Schema

The local database is defined with Drift and currently contains:

### `books`

- `id`
- `name`
- `author`
- `folder_name`
- `pdf_filename`
- `cover_path`
- `total_pages`
- `ocr_progress`
- `ai_progress`
- `language_code`
- `status`
- `file_size`
- `created_at`
- `updated_at`

### `settings`

- `key`
- `value`

Default settings are seeded on first database creation.

### `processing_queue`

- `id`
- `book_id`
- `current_page`
- `phase`
- `status`
- `created_at`

## OCR Strategy

Leaf routes OCR by language/script:

- Bengali and unsupported scripts use Tesseract
- Latin and supported scripts use ML Kit
- Bengali and English tessdata are bundled on Android
- Additional Tesseract languages are intended for on-demand download
- ML Kit packaged modules are checked and installable through native APIs

## Text Processing Strategy

### OCR Persistence

Raw OCR output is stored page-by-page in an `_ocr.json`-style structure.

### Tokenization

The tokenizer is sentence-aware and supports:

- Bengali dari handling
- standard sentence punctuation
- empty OCR page skipping
- force-break fallback when a clean sentence boundary is unavailable

### AI Cleanup

The current AI client targets Google AI Studio `generateContent` endpoints and includes:

- Gemini routing for early pages
- Gemma routing for later pages
- retry handling for:
  - timeouts
  - 429 rate limits
  - 500 and 503 responses
- empty-string fallback on 400 bad request responses

## UI Design Notes

The current UI implementation uses the local mockups in `UI/` as reference and aims for:

- soft paper-like backgrounds
- rounded cards and controls
- muted blue accents
- bottom navigation for library/settings
- spacious reading layout

The visual system is still being refined as more of the reader and processing state become data-driven.

## Development Setup

### Prerequisites

- Flutter SDK installed and available on `PATH`
- Android Studio or Android SDK/command-line tools
- Java 17
- A connected Android device or emulator for native OCR testing

### Install Dependencies

```bash
flutter pub get
```

### Generate Drift Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Analyze

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

### Build Android Debug APK

```bash
cd android
./gradlew assembleDebug
```

## Android Notes

- Application/package namespace: `com.spark.leaf`
- `largeHeap` is enabled for high-DPI page rendering
- `INTERNET` permission is enabled for AI calls and language downloads
- bundled tessdata lives under:
  - `android/app/src/main/assets/tessdata/ben.traineddata`
  - `android/app/src/main/assets/tessdata/eng.traineddata`

## Implemented Tests

The repository currently includes tests covering:

- `Tokenizer`
- `Promptizer`
- `OcrJsonManager`
- `FileService`
- `AiClient`
- `LanguageRegistry`

## Known Gaps

- The full processing orchestrator is not complete yet
- Reader content is not yet fully backed by live cleaned JSON pages
- Create-book currently stores records and starts placeholder processing state
- Settings are displayed, but editing/persistence flow is still minimal
- iOS native support is intentionally deferred

## Roadmap

Short-term priorities:

1. Complete OCR orchestrator and progress synchronization
2. Wire cleaned-page streams into the reader
3. Implement resume/cancel behavior from persisted state
4. Expand settings editing and storage reporting
5. Add integration tests for the full Android pipeline
6. Implement iOS native plugin parity

## Verification Snapshot

The current working tree has been verified with:

- `flutter analyze`
- `flutter test`
- `android/gradlew.bat assembleDebug`

## License

No license file has been added yet. Add one before public distribution if needed.
