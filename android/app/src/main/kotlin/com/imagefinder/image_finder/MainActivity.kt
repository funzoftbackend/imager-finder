package com.imagefinder.image_finder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "com.imagefinder.image_finder/hash_engine"
    private val executor = Executors.newFixedThreadPool(
        Runtime.getRuntime().availableProcessors().coerceAtLeast(2)
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val engine = HashEngine(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "computeContentHash" -> {
                        val uri = call.argument<String>("uri")
                        if (uri.isNullOrBlank()) {
                            result.error("ARG", "uri is required", null)
                            return@setMethodCallHandler
                        }
                        executor.execute {
                            try {
                                val hash = engine.computeContentHash(uri)
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
                                val hash = engine.computeDHash(uri, target)
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
                                val hash = engine.computeDHashFromBytes(bytes)
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
                                val hash = engine.computePHash(uri, target)
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
                                val hash = engine.computePHashFromBytes(bytes)
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
        executor.shutdownNow()
        super.onDestroy()
    }
}
