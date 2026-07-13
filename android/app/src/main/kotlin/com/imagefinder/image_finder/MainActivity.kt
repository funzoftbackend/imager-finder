package com.imagefinder.image_finder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "com.imagefinder.image_finder/hash_engine"
    private val executor = Executors.newFixedThreadPool(
        Runtime.getRuntime().availableProcessors().coerceAtLeast(2),
    )

    private lateinit var hashEngine: HashEngine
    private lateinit var scanEngine: ScanEngine

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        hashEngine = HashEngine(applicationContext)
        scanEngine = ScanEngine(applicationContext, hashEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "catalogImages" -> {
                        executor.execute {
                            try {
                                val rows = scanEngine.catalogImages()
                                runOnUiThread { result.success(rows) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("CATALOG", e.message, null)
                                }
                            }
                        }
                    }
                    "computeDHashBatch" -> {
                        @Suppress("UNCHECKED_CAST")
                        val uris = call.argument<List<String>>("uris")
                        if (uris == null) {
                            result.error("ARG", "uris is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val rows = scanEngine.computeDHashBatch(uris)
                                runOnUiThread { result.success(rows) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("DHASH_BATCH", e.message, null)
                                }
                            }
                        }
                    }
                    "analyzeImage" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrBlank()) {
                            result.error("ARG", "uri is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val row = scanEngine.fingerprintForUri(uri)
                                runOnUiThread { result.success(row) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("ANALYZE", e.message, null)
                                }
                            }
                        }
                    }
                    "computeContentHash" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrBlank()) {
                            result.error("ARG", "uri is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val hash = hashEngine.computeContentHash(uri)
                                runOnUiThread { result.success(hash) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("HASH", e.message, null) }
                            }
                        }
                    }
                    "computeDHash" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrBlank()) {
                            result.error("ARG", "uri is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val target = call.argument<Int>("targetSize") ?: 9
                                val hash = hashEngine.computeDHash(uri, target)
                                runOnUiThread { result.success(hash) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("DHASH", e.message, null) }
                            }
                        }
                    }
                    "computeDHashFromBytes" -> {
                        val raw = call.argument<Any>("bytes")
                        val bytes = when (raw) {
                            is ByteArray -> raw
                            is List<*> -> ByteArray(raw.size) { i ->
                                ((raw[i] as? Number)?.toInt() ?: 0).toByte()
                            }
                            else -> null
                        }
                        if (bytes == null || bytes.isEmpty()) {
                            result.error("ARG", "bytes are required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val hash = hashEngine.computeDHashFromBytes(bytes)
                                runOnUiThread { result.success(hash) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("DHASH", e.message, null) }
                            }
                        }
                    }
                    "computePHash" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrBlank()) {
                            result.error("ARG", "uri is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val target = call.argument<Int>("targetSize") ?: 32
                                val hash = hashEngine.computePHash(uri, target)
                                runOnUiThread { result.success(hash) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("PHASH", e.message, null) }
                            }
                        }
                    }
                    "computePHashFromBytes" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null || bytes.isEmpty()) {
                            result.error("ARG", "bytes are required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val hash = hashEngine.computePHashFromBytes(bytes)
                                runOnUiThread { result.success(hash) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("PHASH", e.message, null) }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        if (::scanEngine.isInitialized) {
            scanEngine.shutdown()
        }
        executor.shutdownNow()
        super.onDestroy()
    }
}
