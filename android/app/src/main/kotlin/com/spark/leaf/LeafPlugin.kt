package com.spark.leaf

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import com.google.android.gms.common.api.OptionalModuleApi
import com.google.android.gms.common.moduleinstall.ModuleInstall
import com.google.android.gms.common.moduleinstall.ModuleInstallRequest
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.googlecode.tesseract.android.TessBaseAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class LeafPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private val pluginScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val tessLock = Any()
    private val tessApis = mutableMapOf<String, TessBaseAPI>()
    private val recognizers = mutableMapOf<String, TextRecognizer>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        recognizers.values.forEach(TextRecognizer::close)
        recognizers.clear()
        destroyTesseractInternal()
        pluginScope.cancel()
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        pluginScope.launch {
            runCatching {
                when (call.method) {
                    "initTesseract" -> {
                        initTesseractInternal()
                        null
                    }
                    "destroyTesseract" -> {
                        destroyTesseractInternal()
                        null
                    }
                    "getPageCount" -> mapOf("count" to getPageCount(call.requireString("pdfPath")))
                    "renderPage" -> mapOf(
                        "imagePath" to renderPage(
                            pdfPath = call.requireString("pdfPath"),
                            pageNum = call.requireInt("pageNum"),
                            dpi = call.requireInt("dpi"),
                        ).absolutePath,
                    )
                    "recognizeWithTesseract" -> mapOf(
                        "text" to recognizeWithTesseract(
                            imagePath = call.requireString("imagePath"),
                            tessCode = call.requireString("tessCode"),
                        ),
                    )
                    "recognizeWithMlKit" -> mapOf(
                        "text" to recognizeWithMlKit(
                            imagePath = call.requireString("imagePath"),
                            script = call.requireString("script"),
                        ),
                    )
                    "ensureMlKitPackage" -> mapOf(
                        "status" to ensureMlKitPackage(call.requireString("script")),
                    )
                    "ensureTessData" -> mapOf(
                        "alreadyPresent" to ensureTessData(call.requireString("tessCode")),
                    )
                    else -> throw IllegalArgumentException("Unsupported method: ${call.method}")
                }
            }.fold(
                onSuccess = { payload ->
                    withContext(Dispatchers.Main) { result.success(payload) }
                },
                onFailure = { error ->
                    withContext(Dispatchers.Main) {
                        result.error("leaf_error", error.message, null)
                    }
                },
            )
        }
    }

    private fun initTesseractInternal() {
        val tessdataDir = File(context.filesDir, "tessdata")
        if (!tessdataDir.exists()) {
            tessdataDir.mkdirs()
        }
        copyAssetIfMissing("tessdata/ben.traineddata", File(tessdataDir, "ben.traineddata"))
        copyAssetIfMissing("tessdata/eng.traineddata", File(tessdataDir, "eng.traineddata"))
        synchronized(tessLock) {
            if (!tessApis.containsKey("ben")) {
                tessApis["ben"] = createTesseractApi("ben")
            }
            if (!tessApis.containsKey("eng")) {
                tessApis["eng"] = createTesseractApi("eng")
            }
        }
    }

    private fun destroyTesseractInternal() {
        synchronized(tessLock) {
            tessApis.values.forEach(TessBaseAPI::recycle)
            tessApis.clear()
        }
    }

    private fun getPageCount(pdfPath: String): Int {
        ParcelFileDescriptor.open(File(pdfPath), ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
            PdfRenderer(descriptor).use { renderer ->
                return renderer.pageCount
            }
        }
    }

    private fun renderPage(pdfPath: String, pageNum: Int, dpi: Int): File {
        val sourceFile = File(pdfPath)
        val pageIndex = pageNum - 1
        val outputFileName = "leaf_p${pageNum}_${sourceFile.nameWithoutExtension.hashCode()}.png"
        val outputFile = File(context.cacheDir, outputFileName)
        ParcelFileDescriptor.open(sourceFile, ParcelFileDescriptor.MODE_READ_ONLY).use { descriptor ->
            PdfRenderer(descriptor).use { renderer ->
                renderer.openPage(pageIndex).use { page ->
                    val scale = dpi / 72f
                    val bitmap = Bitmap.createBitmap(
                        (page.width * scale).toInt().coerceAtLeast(1),
                        (page.height * scale).toInt().coerceAtLeast(1),
                        Bitmap.Config.ARGB_8888,
                    )
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    FileOutputStream(outputFile).use { stream ->
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                    }
                    bitmap.recycle()
                }
            }
        }
        return outputFile
    }

    private fun recognizeWithTesseract(imagePath: String, tessCode: String): String {
        val imageFile = File(imagePath)
        val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            ?: throw IllegalStateException("Unable to decode image at $imagePath")
        return try {
            synchronized(tessLock) {
                val api = tessApis.getOrPut(tessCode) { createTesseractApi(tessCode) }
                api.setImage(bitmap)
                api.getUTF8Text().orEmpty()
            }
        } finally {
            bitmap.recycle()
            imageFile.delete()
        }
    }

    private fun recognizeWithMlKit(imagePath: String, script: String): String {
        val imageFile = File(imagePath)
        val bitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            ?: throw IllegalStateException("Unable to decode image at $imagePath")
        return try {
            val image = InputImage.fromBitmap(bitmap, 0)
            val text = Tasks.await(recognizerFor(script).process(image))
            text.textBlocks.joinToString("\n") { block: Text.TextBlock -> block.text }
        } finally {
            bitmap.recycle()
            imageFile.delete()
        }
    }

    private fun ensureMlKitPackage(script: String): String {
        val recognizer = recognizerFor(script)
        val moduleInstallClient = ModuleInstall.getClient(context)
        val moduleApi = recognizer as OptionalModuleApi
        var availability = Tasks.await(moduleInstallClient.areModulesAvailable(moduleApi))
        if (availability.areModulesAvailable()) {
            return "ready"
        }
        val request = ModuleInstallRequest.newBuilder()
            .addApi(moduleApi)
            .build()
        return try {
            Tasks.await(moduleInstallClient.installModules(request))
            availability = Tasks.await(moduleInstallClient.areModulesAvailable(moduleApi))
            if (availability.areModulesAvailable()) "ready" else "failed"
        } catch (_: Exception) {
            "failed"
        }
    }

    private fun ensureTessData(tessCode: String): Boolean {
        val codes = tessCode.split("+")
        var allPresent = true
        for (code in codes) {
            val destination = File(context.filesDir, "tessdata/$code.traineddata")
            if (!destination.exists()) {
                if (!downloadTessData(code, destination)) {
                    allPresent = false
                }
            }
        }
        return allPresent
    }

    private fun recognizerFor(script: String): TextRecognizer {
        return recognizers.getOrPut(script) {
            when (script) {
                "latin" -> TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                "chinese" -> TextRecognition.getClient(
                    ChineseTextRecognizerOptions.Builder().build(),
                )
                "devanagari" -> TextRecognition.getClient(
                    DevanagariTextRecognizerOptions.Builder().build(),
                )
                "japanese" -> TextRecognition.getClient(
                    JapaneseTextRecognizerOptions.Builder().build(),
                )
                "korean" -> TextRecognition.getClient(
                    KoreanTextRecognizerOptions.Builder().build(),
                )
                else -> throw IllegalArgumentException("Unsupported ML Kit script: $script")
            }
        }
    }

    private fun copyAssetIfMissing(assetPath: String, destination: File) {
        if (destination.exists()) {
            return
        }
        destination.parentFile?.mkdirs()
        context.assets.open(assetPath).use { input ->
            FileOutputStream(destination).use { output ->
                input.copyTo(output)
            }
        }
    }

    private fun createTesseractApi(language: String): TessBaseAPI {
        val api = TessBaseAPI()
        val initialized = api.init(context.filesDir.absolutePath, language)
        if (!initialized) {
            api.recycle()
            throw IllegalStateException("Failed to initialize Tesseract for $language")
        }
        return api
    }

    private fun MethodCall.requireString(key: String): String {
        return argument<String>(key) ?: throw IllegalArgumentException("Missing argument: $key")
    }

    private fun MethodCall.requireInt(key: String): Int {
        return argument<Int>(key) ?: throw IllegalArgumentException("Missing argument: $key")
    }

    private fun downloadTessData(tessCode: String, destination: File): Boolean {
        val sourceUrl = URL("$TESSDATA_BASE_URL/$tessCode.traineddata")
        var connection: HttpURLConnection? = null
        return try {
            destination.parentFile?.mkdirs()
            connection = (sourceUrl.openConnection() as HttpURLConnection).apply {
                connectTimeout = 15_000
                readTimeout = 60_000
                requestMethod = "GET"
                instanceFollowRedirects = true
            }
            connection.connect()
            if (connection.responseCode !in 200..299) {
                false
            } else {
                BufferedInputStream(connection.inputStream).use { input ->
                    FileOutputStream(destination).use { output ->
                        input.copyTo(output)
                    }
                }
                destination.exists() && destination.length() > 0
            }
        } catch (_: Exception) {
            if (destination.exists()) {
                destination.delete()
            }
            false
        } finally {
            connection?.disconnect()
        }
    }

    private companion object {
        const val CHANNEL_NAME = "com.spark.leaf/native"
        const val TESSDATA_BASE_URL =
            "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main"
    }
}
