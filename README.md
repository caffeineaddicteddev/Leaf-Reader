# 🍃 Leaf

**Turn any scanned book into readable text — on your phone, in any language.**

Leaf takes a PDF of a scanned or photographed book, runs it through an OCR pipeline, and produces clean, readable text using AI. You read the result in a distraction-free reader that feels like a document — not a PDF viewer. The original PDF is just the source. What you actually read is living text.

It was built first for Bengali, because Bengali has hundreds of thousands of books published before the digital age that are effectively inaccessible to anyone without a physical copy. But the pipeline works in 22 languages, and the problem it solves is universal.

---

## Why this exists

Somewhere between 1950 and 1990, an enormous amount of human writing — novels, poetry, scholarship, folklore, journalism — was printed and never digitized. Most of it sits in institutional archives, personal collections, and secondhand bookshops. Some of it is slowly deteriorating. Very little of it is searchable, shareable, or accessible to anyone who doesn't already have the physical object in their hands.

For major world languages, commercial digitization projects have made a dent. For Bengali, Tamil, Punjabi, Burmese, and dozens of other languages spoken by hundreds of millions of people, the gap remains enormous. The tools that exist are either expensive, English-centric, or require technical knowledge most people don't have.

Leaf is an attempt to make the barrier as low as possible. If you have a scanned PDF of a book and a phone, you can have readable text in minutes. The AI correction step means even degraded, noisy, century-old print produces usable output. You don't need a computer science degree. You don't need to pay for enterprise software. You need a PDF and a free API key.

Making text accessible is not a small thing. Text that can be read can be searched. Text that can be searched can be found. Text that can be found can be shared, cited, translated, taught from, and built upon. Every book that moves from a scanned image into living text is a book that rejoins the conversation.

---

## What it does

```
PDF (scanned book)
      ↓
Page-by-page rendering at 300 DPI
      ↓
OCR — Bengali/complex scripts via Tesseract
      All other scripts via ML Kit
      ↓
Raw text saved to bookname_ocr.json  (updates continuously)
      ↓
Sentence-boundary tokenization  (respects Bengali dari ।)
      ↓
AI cleanup via Google AI Studio
  Pages 1–10  → Gemini  (strips preface, corrects errors)
  Pages 11+   → Gemma  (corrects errors only)
      ↓
Clean text saved to bookname_clean.json  (updates continuously)
      ↓
Google Docs-style reader UI
```

You can start reading before the full book finishes processing. The first page appears in the reader as soon as it returns from the AI. The rest arrives as you read.

---

## Features

- **22 languages** — Bengali, Arabic, Hindi, Chinese (Simplified + Traditional), Japanese, Korean, Tamil, Telugu, Malayalam, Kannada, Gujarati, Punjabi, Burmese, Thai, English, Spanish, French, German, Italian, Portuguese, Russian, Marathi
- **Offline OCR** — Bengali and English are bundled in the app. Other languages download once on first use. No internet required for OCR after that.
- **AI correction** — Gemini and Gemma clean up OCR noise, fix broken characters, and strip prefaces automatically. You bring your own API key — no subscription, no middleman.
- **Reads while processing** — OCR and AI cleanup run in parallel. You don't wait for the whole book. The reader opens after the first page is done.
- **Google Docs-style reader** — Clean, typographic, distraction-free. Kalpurush font for Bengali. Adjustable text size.
- **Fully local** — Everything stays on your device. PDFs, OCR output, cleaned text — none of it leaves your phone unless you export it.
- **No account required** — Open the app, import a PDF, read.

---

## Download

### Android

> Minimum Android version: Android 8.0 (API 26)

| Channel | Link |
|---|---|
| **Alpha** | [Download APK](https://github.com/caffeineaddicteddev/Leaf-Reader/releases) |

**How to install:**
1. Download the APK from the link above
2. Open the downloaded file on your Android device
3. If prompted, allow installation from unknown sources — go to Settings → Security → Install unknown apps and enable it for your browser or file manager
4. Tap Install

### iOS

iOS support is not available yet. It is planned for a future release.

---

## Getting your API key (2 minutes)

Leaf uses Google AI Studio for the text correction step. The free tier is more than enough for personal use — you do not need a billing account or a new Google Cloud project.

### Step 1 — Open Google AI Studio

Go to [aistudio.google.com](https://aistudio.google.com) and sign in with any Google account.

### Step 2 — Create an API key

- Click **Get API key** in the left sidebar
- Click **Create API key**
- Select **Create API key in new project** — Google sets up a default Gemini project automatically, nothing to configure
- Copy the key that appears

That's it. No billing setup. No project configuration.

### Step 3 — Enter the key in Leaf

- Open Leaf on your phone
- Tap the **Settings** tab (bottom navigation bar)
- Paste your key into the **Google AI Studio API Key** field

Your key is stored locally on your device. It is only ever sent to Google's own API — never to any third-party server.

### Free tier limits

As of 2026, Google AI Studio's free tier includes:

| Model | Free limit |
|---|---|
| Gemini 3 Flash | 20 requests/day |
| Gemini 3.1 Flash lite | 500 requests/day |
| Gemma 3 | 14,400 requests/day |

For personal book reading you will rarely hit these limits. If you do, Leaf pauses and retries automatically when the limit resets.

---

## User manual

### Importing a book

1. Tap the **+** button on the Library screen
2. Enter a book name (required) and author name (optional)
3. Choose the language of the book from the dropdown
4. Tap **Select PDF** and pick your file
5. Tap **Create**

Leaf copies the PDF into its own storage folder. You can safely delete or move the original file after importing.

### The processing screen

After creating a book, the processing screen shows:

- **Outer ring** — OCR progress (pages scanned so far)
- **Inner ring** — AI cleanup progress (pages ready to read)

You can tap **Open Book** as soon as the inner ring shows any progress. You do not need to wait for the full book to finish. Reading while processing is the normal way to use Leaf.

Tapping **Cancel** stops processing and resets the book. All partial progress is cleared.

If you close the app during processing, Leaf resumes from where it left off when you reopen it.

### Reading

The reader shows AI-cleaned text. Pages not yet processed appear as placeholder blocks and fill in automatically as processing continues.

- Tap the **A** button to cycle through three font sizes
- Your position is saved automatically when you leave the reader
- Bengali books use the Kalpurush typeface

### Language data downloads

Selecting a language for the first time triggers a one-time download before processing starts:

| Language | Download |
|---|---|
| Bengali | None — bundled |
| English | None — bundled |
| Arabic, Tamil, Telugu, and other Tesseract languages | 2–15 MB |
| Hindi, Marathi (Devanagari) | ML Kit on-demand package |
| Chinese, Japanese, Korean | ML Kit on-demand package |

Downloads happen automatically. A progress indicator appears on the processing screen while downloading.

### Settings reference

| Setting | What it does |
|---|---|
| Google AI Studio API Key | Required for AI text correction — see setup above |
| Gemini Model | Model for pages 1–10. Default: `gemini-3-flash` |
| Gemma Model | Model for pages 11+. Default: `gemma-3-27b-it` |
| Theme | Light, Dark, or follow system setting |

The model fields accept any valid Google AI Studio model name. You can switch to newer models as they are released without waiting for an app update.

### Editing a book

Long-press any book card, you can change the book name and author. Language cannot be changed after creation.

### Deleting a book

Long-press any book card → tap **Delete**. This permanently removes the book record, the copied PDF, and all OCR and cleaned text files from your device.

---

## Technical overview

### Architecture

```
Flutter (Dart)
  ├── UI            Riverpod 2 · go_router · Material 3
  ├── Pipeline      OCR orchestrator · tokenizer · promptizer · AI client
  ├── Storage       Drift (SQLite) · JSON files via dart:io
  └── Platform plugin  (MethodChannel: com.spark.leaf/native)
        ├── Android (Kotlin)
        │     ├── PDF rendering    Android PdfRenderer  (built-in, API 21+)
        │     ├── Complex OCR      Tesseract4Android 4.8.0
        │     └── Other OCR        ML Kit Text Recognition
        └── iOS (Swift) — planned
              ├── PDF rendering    PDFKit
              ├── Complex OCR      SwiftyTesseract
              └── Other OCR        ML Kit for Swift
```

### OCR engine routing

| Engine | Languages |
|---|---|
| Tesseract (tessdata_fast) | Bengali · Arabic · Tamil · Telugu · Malayalam · Kannada · Gujarati · Punjabi · Burmese · Thai |
| ML Kit — Latin base | English · Spanish · French · German · Italian · Portuguese · Russian |
| ML Kit — Devanagari | Hindi · Marathi |
| ML Kit — CJK | Chinese (Simplified + Traditional) · Japanese |
| ML Kit — Korean | Korean |

Bengali and English traineddata files are bundled in the APK. All other Tesseract languages are downloaded from the [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) repository on first use.

### AI pipeline

**Pages 1–10 — Gemini**
Early pages of scanned books often contain prefaces, tables of contents, and publisher information that are not part of the actual book content. Gemini strips this material and outputs only the book's narrative content, corrected for OCR errors. If Gemini is rate-limited, the pipeline waits 30 seconds and retries automatically.

**Pages 11+ — Gemma**
Once past the preliminary pages, Gemma 3 27B handles correction only — no restructuring, no stripping, just fixing what OCR got wrong. If 27B is busy, it falls back to 12B, then 4B, with automatic retry.

**Tokenizer**
The tokenizer ensures no broken sentence is ever sent to the AI. It reads from the raw OCR JSON and splits at sentence boundaries: Bengali dari (।), English full stops, question marks, and exclamation marks. When a page ends mid-sentence, the tokenizer looks ahead into the next page's OCR output to find the boundary before sending the chunk.

### Local storage layout

```
LeafLibrary/
  └── bookname_uuid4/
        ├── original.pdf            copied from import location
        ├── bookname_ocr.json       raw OCR, grows page by page during processing
        ├── bookname_clean.json     AI-cleaned text, grows page by page
        └── cover.png               first-page thumbnail for library card
```

The JSON files grow continuously during processing. The reader watches `_clean.json` and adds new pages to the UI as they arrive.

### Database schema (SQLite via Drift)

**books** — one row per imported book, tracks processing progress and metadata

**settings** — key-value table for API keys, model selection, theme preference

**processing_queue** — tracks OCR and AI phase progress for pipeline resumption after app restart

### Key dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `drift` | Type-safe SQLite ORM |
| `dio` | HTTP — Google AI Studio API calls |
| `file_picker` | PDF import |
| `Tesseract4Android` | Native OCR for Bengali and complex scripts (Android) |
| `ML Kit Text Recognition` | Native OCR for Latin, CJK, Devanagari, Korean (Android) |

---

## Building from source

**Prerequisites**
- Flutter 3.x stable channel (`flutter channel stable && flutter upgrade`)
- Android Studio with Android SDK
- A Google AI Studio API key for testing the full pipeline

```bash
# Clone the repository
git clone https://github.com/caffeineaddicteddev/Leaf-Reader.git
cd leaf

# Install dependencies
flutter pub get

# Run code generation (Drift tables + Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Connect an Android device or start an emulator, then run
flutter run
```

The Bengali and English tessdata files are included in the repository at `android/app/src/main/assets/tessdata/`. No additional downloads are needed to build and run.

---

## Contributing

Contributions are welcome — bug reports, language improvements, UI feedback, or pull requests.

If you are working on a digitization project for any language and want to use or adapt Leaf's pipeline, feel free to reach out. Collaboration with libraries, archives, and cultural institutions is something this project actively wants to support.

Please open an issue before submitting a large pull request so we can discuss the approach first.

---

## License

AGPL v3 License — see [LICENSE](LICENSE) for the full text.

---

## Acknowledgements

- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) — the open source OCR engine powering offline recognition for Bengali and other complex scripts
- [tessdata_fast](https://github.com/tesseract-ocr/tessdata_fast) — the trained model files used by Tesseract in Leaf
- [Tesseract4Android](https://github.com/adaptech-cz/Tesseract4Android) — the Android library that made Tesseract integration possible without NDK complexity
- [Google ML Kit](https://developers.google.com/ml-kit) — on-device text recognition for Latin, CJK, Devanagari, and Korean scripts
- [Kalpurush](https://www.omicronlab.com/) — the Bengali typeface used in the reader UI

---

*Created by [@Sajid](https://github.com/caffeineaddicteddev)*
