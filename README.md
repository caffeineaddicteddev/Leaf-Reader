# Leaf

Leaf is a Flutter-based reader for scanned PDF books. It imports a PDF, runs OCR page by page, stores the extracted text locally, and lets you read the result inside a clean in-app reader instead of staying inside the raw PDF viewer.

The project is currently in `v0.2.0-alpha` and is still focused mainly on the Android app flow.

## Current Project Status

Leaf already has a working end-to-end flow for:

- creating a book entry from a PDF
- selecting an OCR language
- generating a cover image from the first page
- running OCR page by page
- saving OCR output to local JSON files
- opening the reader before all processing is finished
- saving reading progress
- toggling AI mode on or off per book
- editing book metadata
- deleting imported books
- changing the saved library directory
- switching between light, dark, and system theme

## What Exists Right Now

### Library

The app has a library screen with book cards, search UI, create-book flow, edit metadata, and delete actions.

### Processing

After import, Leaf starts processing the PDF. It renders pages natively on Android, performs OCR, writes intermediate data to disk, and can continue work when the app is reopened.

### Reader

The reader loads processed text from local storage and keeps updating as more content becomes available. Reading position and scroll offset are saved.

### AI Mode

Leaf includes an AI mode setting plus model and API key configuration. When enabled and configured, the app can run AI cleanup on OCR text using Google AI Studio models.

## OCR and Language Support

The codebase currently includes a language registry for multiple OCR options, with Tesseract used for some scripts and ML Kit used for others.

Bundled by default:

- Bengali
- Bengali+English
- English

Other listed languages may require downloaded model data or additional platform preparation before OCR can run correctly.

## Platform Situation

This repository contains Flutter folders for Android, iOS, macOS, Linux, Windows, and web, but the implemented native OCR pipeline in this project is currently Android-first.

Practical status right now:

- Android: primary target and current working platform
- iOS/macOS/Linux/Windows/web: project scaffolding exists, but the OCR pipeline and app behavior should not be considered complete or production-ready there

## Tech Stack

- Flutter
- Riverpod
- go_router
- Drift + SQLite
- Dio
- File Picker
- Android native plugin in Kotlin
- Tesseract
- Google ML Kit
- Google AI Studio API

## Local Data Flow

At a high level, the app works like this:

`PDF -> rendered pages -> OCR text -> local JSON -> optional AI cleanup -> reader`

Book files are copied into the app library, and OCR / cleaned output is stored locally per imported book.

## Build and Run

### Requirements

- Flutter stable
- Android SDK / Android Studio
- an Android device or emulator

### Run locally

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Notes for Contributors

This repository is still evolving, and some parts are clearly ahead of others. The README is intentionally grounded in the code that is present now rather than the long-term roadmap.

If you update platform support, AI flow, or OCR behavior, the README should be updated to match the actual shipped state.

## License

AGPL v3. See [LICENSE](LICENSE).

## AI Correction

AI mode is still under development.

At the moment, only Bangali and English works reliably in OCR and AI correction mode. Other languages might fail.
