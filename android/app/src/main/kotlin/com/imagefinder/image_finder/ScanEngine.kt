package com.imagefinder.image_finder

import android.content.ContentUris
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.os.CancellationSignal
import android.provider.MediaStore
import android.util.Size
import java.util.concurrent.Callable
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit

/**
 * Native MediaStore bulk catalog + parallel thumbnail dHash.
 * Designed for Play-Store-class first-scan speed.
 */
class ScanEngine(
    private val context: Context,
    private val hashEngine: HashEngine,
) {
    private val poolSize = Runtime.getRuntime().availableProcessors().coerceIn(4, 8)
    private val pool = Executors.newFixedThreadPool(poolSize)

    /**
     * Single-cursor inventory with SIZE column — avoids per-photo IPC from Flutter.
     */
    fun catalogImages(): List<Map<String, Any?>> {
        val projection = mutableListOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DATE_MODIFIED,
            MediaStore.Images.Media.DATE_ADDED,
            MediaStore.Images.Media.WIDTH,
            MediaStore.Images.Media.HEIGHT,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.MIME_TYPE,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            projection.add(MediaStore.Images.Media.RELATIVE_PATH)
        }

        val sortOrder = "${MediaStore.Images.Media.DATE_MODIFIED} DESC"
        val out = ArrayList<Map<String, Any?>>(4096)

        context.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection.toTypedArray(),
            null,
            null,
            sortOrder,
        )?.use { cursor ->
            val idCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val modCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_MODIFIED)
            val addCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
            val wCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.WIDTH)
            val hCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.HEIGHT)
            val sizeCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val mimeCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.MIME_TYPE)
            val pathCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                cursor.getColumnIndex(MediaStore.Images.Media.RELATIVE_PATH)
            } else {
                -1
            }

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                val uri = ContentUris.withAppendedId(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    id,
                ).toString()
                val path = if (pathCol >= 0) cursor.getString(pathCol) else null
                out.add(
                    mapOf(
                        "mediaId" to id.toString(),
                        "uri" to uri,
                        "path" to path,
                        "width" to cursor.getInt(wCol),
                        "height" to cursor.getInt(hCol),
                        "sizeBytes" to cursor.getLong(sizeCol),
                        "modifiedMs" to cursor.getLong(modCol) * 1000L,
                        "createdMs" to cursor.getLong(addCol) * 1000L,
                        "mime" to cursor.getString(mimeCol),
                        "album" to path,
                    ),
                )
            }
        }

        return out
    }

    /**
     * Parallel fingerprint (dHash + dark/blur scores) via system thumbnails.
     * Returns maps: { uri, dHash, meanLuminance, blurScore } (nulls on failure).
     */
    fun computeDHashBatch(uris: List<String>): List<Map<String, Any?>> {
        if (uris.isEmpty()) return emptyList()

        val futures = ArrayList<Future<Map<String, Any?>>>(uris.size)
        for (uri in uris) {
            futures.add(
                pool.submit(
                    Callable {
                        try {
                            fingerprintForUri(uri)
                        } catch (_: Exception) {
                            failedFingerprint(uri)
                        }
                    },
                ),
            )
        }

        return List(futures.size) { index ->
            try {
                futures[index].get(30, TimeUnit.SECONDS)
            } catch (_: Exception) {
                failedFingerprint(uris[index])
            }
        }
    }

    fun fingerprintForUri(uriString: String): Map<String, Any?> {
        val uri = android.net.Uri.parse(uriString)
        val thumb = loadSystemThumbnail(uri)
        if (thumb != null) {
            try {
                val fp = hashEngine.fingerprintFromBitmap(thumb)
                return mapOf(
                    "uri" to uriString,
                    "dHash" to fp.dHash,
                    "meanLuminance" to fp.meanLuminance,
                    "blurScore" to fp.blurScore,
                )
            } finally {
                thumb.recycle()
            }
        }
        val fp = hashEngine.fingerprintFromUri(uriString)
        return mapOf(
            "uri" to uriString,
            "dHash" to fp.dHash,
            "meanLuminance" to fp.meanLuminance,
            "blurScore" to fp.blurScore,
        )
    }

    private fun failedFingerprint(uri: String): Map<String, Any?> = mapOf(
        "uri" to uri,
        "dHash" to null,
        "meanLuminance" to null,
        "blurScore" to null,
    )

    /** 64×64 thumbs — enough for Laplacian blur without full-res decode. */
    private fun loadSystemThumbnail(uri: android.net.Uri): Bitmap? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val signal = CancellationSignal()
                context.contentResolver.loadThumbnail(uri, Size(64, 64), signal)
            } else {
                @Suppress("DEPRECATION")
                MediaStore.Images.Thumbnails.getThumbnail(
                    context.contentResolver,
                    ContentUris.parseId(uri),
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    null,
                )
            }
        } catch (_: Exception) {
            null
        }
    }

    fun shutdown() {
        pool.shutdownNow()
    }
}
