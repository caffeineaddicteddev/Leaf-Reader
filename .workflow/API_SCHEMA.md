# API Schema Definition

## Flutter (Dart) ↔ Kotlin Plugin Interface
- **Channel Name**: `com.spark.leaf/native`

### Method: `initTesseract`
- **Direction**: Flutter → Kotlin
- **Input parameters**: None
- **Return type**: `void`
- **Side effects**: Initializes Tesseract directories and copies default assets (`ben.traineddata`, `eng.traineddata`).

### Method: `destroyTesseract`
- **Direction**: Flutter → Kotlin
- **Input parameters**: None
- **Return type**: `void`
- **Side effects**: Recycles Tesseract base APIs.

### Method: `getPageCount`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `pdfPath` | String | Yes | Absolute path to the PDF file |
- **Return type**: `Map<String, Int>`
- **Return schema**: `{ "count": Int }`

### Method: `renderPage`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `pdfPath` | String | Yes | Absolute path to the PDF file |
  | `pageNum` | Int | Yes | 1-indexed page number |
  | `dpi` | Int | Yes | Rendering density |
- **Return type**: `Map<String, String>`
- **Return schema**: `{ "imagePath": String }` (Path to cached bitmap)

### Method: `recognizeWithTesseract`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `imagePath` | String | Yes | Path to bitmap |
  | `tessCode` | String | Yes | Tesseract language code (e.g., `ben+eng`) |
- **Return type**: `Map<String, String>`
- **Return schema**: `{ "text": String }`
- **Side effects**: Deletes the source bitmap after processing.

### Method: `recognizeWithMlKit`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `imagePath` | String | Yes | Path to bitmap |
  | `script` | String | Yes | ML Kit script (e.g., `latin`, `chinese`) |
- **Return type**: `Map<String, String>`
- **Return schema**: `{ "text": String }`
- **Side effects**: Deletes the source bitmap after processing.

### Method: `ensureMlKitPackage`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `script` | String | Yes | ML Kit script code |
- **Return type**: `Map<String, String>`
- **Return schema**: `{ "status": "ready" | "failed" }`

### Method: `ensureTessData`
- **Direction**: Flutter → Kotlin
- **Input parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | `tessCode` | String | Yes | Tesseract language code |
- **Return type**: `Map<String, Boolean>`
- **Return schema**: `{ "alreadyPresent": Boolean }`
