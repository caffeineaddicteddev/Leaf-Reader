# Decisions Log

## [DECISION-001] Flutter + Kotlin Platform Plugin Architecture
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: Needed a cross-platform UI framework with deep access to native Android features (PdfRenderer, specific OCR engines).
- **Decision**: Use Flutter for the app layer and a custom native Kotlin plugin (`com.spark.leaf`) for processing.
- **Alternatives considered**: Pure Flutter, Pure Native.
- **Consequences**: Enables high-performance native ML integrations while keeping UI development fast in Flutter.

## [DECISION-002] Tesseract4Android for Bengali and Unsupported Scripts
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: ML Kit lacks strong Bengali support.
- **Decision**: Use Tesseract4Android for Bengali OCR.
- **Alternatives considered**: ML Kit for everything.
- **Consequences**: Support for Bengali at the cost of bundled training data.

## [DECISION-003] ML Kit for Latin/CJK/Devanagari/Korean
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: Need fast, reliable on-device OCR for common scripts.
- **Decision**: Use on-device ML Kit for supported scripts.
- **Alternatives considered**: Tesseract for everything.
- **Consequences**: Fast, high-accuracy OCR for common scripts.

## [DECISION-004] Cloud AI (Gemini 3 Flash & Gemma 3) for Text Correction
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: OCR models produce substitution errors (ৰ→র). Advanced correction is needed.
- **Decision**: Route OCR text through Google AI Studio API using Gemini 3 Flash (primary) and Gemma 3 (secondary).
- **Alternatives considered**: On-device LLMs (LiteRT).
- **Consequences**: Requires network access for best correction quality.

## [DECISION-005] Drift SQLite for Persistence
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: Need robust, relational local storage.
- **Decision**: Use Drift SQLite.
- **Alternatives considered**: Hive, raw SQLite.
- **Consequences**: Type-safe relational database in Dart.

## [DECISION-006] AGPL v3 Licensing
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: Strategic goal for community/grant alignment.
- **Decision**: Open source as AGPL v3.
- **Consequences**: Strong copyleft requirements.

## [DECISION-007] LiteRT/TFLite (On-Device Inference) [DEPRECATED/PLANNED]
- **Date**: 2026-04-02
- **Status**: Deprecated
- **Context**: Initial plan included on-device Gemma.
- **Decision**: Shifted to Cloud API for v0.1.x to ensure reliability and lower initial app size.
- **Superseded by**: [DECISION-004]

## [DECISION-008] fastText for Language Detection [DEPRECATED/PLANNED]
- **Date**: 2026-04-02
- **Status**: Deprecated
- **Context**: Routing between Tesseract and ML Kit.
- **Decision**: Currently handled by App Layer logic / user interaction rather than automated fastText detection.
- **Consequences**: Simplified native plugin logic.

## [DECISION-009] Use permission_handler for Scoped Storage
- **Date**: 2026-04-02
- **Status**: Accepted
- **Context**: On Android 11+, reading/writing to arbitrary external directories selected by `file_picker` fails using standard `dart:io` without the `MANAGE_EXTERNAL_STORAGE` permission.
- **Decision**: Add `permission_handler` dependency and request `MANAGE_EXTERNAL_STORAGE` when changing the library directory to an external path.
- **Alternatives considered**: Using `shared_storage` (more complex API, requires migrating entire app away from `dart:io`).
- **Consequences**: Fixes book creation failures on Android 11+ after picking external folders. App needs to prompt user for "All Files Access".
