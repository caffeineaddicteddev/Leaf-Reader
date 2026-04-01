# Project Specification: Leaf v0.1.x

## Product Purpose
Leaf is a highly optimized, local-first PDF reading application designed to provide flawless OCR, specifically targeting the complexities of Bengali scripts and challenging legacy document structures. It bridges the gap between raw OCR and human-readable text using an AI-assisted correction pipeline.

## Target Users
- **Primary:** Researchers, scholars, and avid readers working with scanned Bengali literature and historical documents.
- **Secondary:** General users requiring high-quality offline document reading and OCR capabilities across multiple languages.

## Supported Input Formats
- Current: PDF
- Future: EPUB, CBZ, images.

## Supported Languages
Targeting 22 languages. Primary focus on **Bengali**.
Supported ML Kit Scripts: Latin, Chinese, Devanagari, Japanese, Korean.

## OCR Engine Routing Rules
- **Bengali & Unsupported Scripts:** Routed by the App Layer to **Tesseract4Android**.
- **Supported Scripts (Latin/CJK/etc.):** Routed to **ML Kit**.
- **Logic:** The Flutter app determines the engine based on user selection or script detection logic managed in Dart.

## AI Correction Behavior
- **Trigger:** Runs automatically after raw text extraction if enabled and an API key is provided.
- **Models:** Uses Google AI Studio API.
  - **Primary:** Gemini 3 Flash.
  - **Fallback:** Gemini 3.1 Flash Lite, Gemini 2.5 Flash, Gemma 3 (IT variants).
- **Online Only:** AI correction requires an internet connection in v0.1.x.
- **Guarantees:** Will attempt to fix common OCR substitution errors (e.g., Bengali `ৰ` → `র`).
- **Disclaimers:** Generative AI may hallucinate; original image is always the source of truth.

## Output Formats
- In-app reading interface synchronizing the original page rendering with an overlay or split-screen of the corrected text.
- SQLite database (Drift) containing processed plain text per page.

## Performance Targets
- **Max processing time per page:** < 2 seconds for OCR, < 5 seconds for Cloud AI correction (network dependent).
- **Model load time:** < 1 second for ML Kit.

## Known Limitations in v0.1.x
- No offline AI correction.
- Requires user to provide their own Google AI Studio API key.

## Out of Scope for v0.1.x
- On-device LLM inference (LiteRT).
- Automated language detection (fastText).
- Cloud synchronization.

## Open Questions
- Optimal prompt engineering for specific Bengali dialect correction.
- UX for managing "ready" status of ML Kit modules.
