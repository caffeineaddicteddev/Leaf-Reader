# Architecture

## System Flow Diagram

```mermaid
graph TD
    A[PDF Input] --> B[Flutter UI]
    B --> C[Method Channel (com.spark.leaf/native)]
    C --> D[Native PdfRenderer]
    D --> E[Page Bitmap (Disk Cache)]
    
    E --> F{OCR Routing (App Layer)}
    F -->|Bengali / Unsupported| G[Tesseract4Android]
    F -->|Latin / CJK / Devanagari| H[ML Kit]
    
    G --> I[Raw Text]
    H --> I
    
    I --> J{AI Correction Pipeline}
    J -->|Cloud API| K[Gemini 3 Flash]
    J -->|Cloud API| L[Gemma 3 IT]
    
    K --> M[Corrected Text]
    L --> M
    
    M --> N[Drift SQLite Storage]
    N --> O[Flutter UI Update]
```

## Layers

### 1. App Layer (Flutter)
- **UI:** Handles user interactions, PDF selection, reading view, processing status.
- **State Management:** Manages application state, selected documents, reading progress, and processing queues.
- **File Handling:** Manages PDF files from the file system, passing URIs to the native layer.
- **Document Flow:** Orchestrates the processing pipeline by coordinating calls between the native plugin and AI cloud services. It determines which OCR engine to use based on script/language.

### 2. Platform Plugin Layer (Kotlin)
- **PdfRenderer:** Uses Android's native `PdfRenderer` to rasterize PDF pages into bitmaps stored in cache.
- **Tesseract4Android Integration:** Wraps the Tesseract library for OCR operations on bitmap files.
- **ML Kit Integration:** Wraps Google's ML Kit Vision API for OCR operations.
- **Method Channel API Surface:** `com.spark.leaf/native` channel for low-level document processing.

### 3. AI Correction Pipeline (Cloud)
- **Primary:** Gemini 3 Flash (via Google AI Studio API). High accuracy, cloud-based REST interface.
- **Secondary:** Gemma 3 variants (via the same API endpoint).
- **Invocation:** Triggered by `AiClient` after raw OCR text is returned from the native layer.
- **Input/Output Contract:** Takes raw text and specialized prompts to output error-corrected text.

### 4. Storage Layer
- **Technology:** Drift SQLite.
- **Entities:**
  - `Document`: Metadata about a PDF (URI, title, author, hash, last read page).
  - `Page`: OCR'd text content per page, associated with a Document.