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
     * Parallel dHash using system thumbnails when available.
     * Returns one map per input uri: { uri, dHash } (dHash null on failure).
     */
    fun computeDHashBatch(uris: List<String>): List<Map<String, String?>> {
        if (uris.isEmpty()) return emptyList()

        val futures = ArrayList<Future<Map<String, String?>>>(uris.size)
        for (uri in uris) {
            futures.add(
                pool.submit(
                    Callable {
                        try {
                            val hash = dHashForUri(uri)
                            mapOf("uri" to uri, "dHash" to hash)
                        } catch (_: Exception) {
                            mapOf("uri" to uri, "dHash" to null)
                        }
                    },
                ),
            )
        }

        return List(futures.size) { index ->
            try {
                futures[index].get(30, TimeUnit.SECONDS)
            } catch (_: Exception) {
                mapOf("uri" to uris[index], "dHash" to null)
            }
        }
    }

    private fun dHashForUri(uriString: String): String {
        val uri = android.net.Uri.parse(uriString)
        val thumb = loadSystemThumbnail(uri)
        if (thumb != null) {
            try {
                return hashEngine.dHashFromBitmapPublic(thumb)
            } finally {
                thumb.recycle()
            }
        }
        // Fallback: sampled decode (still native, no Dart).
        return hashEngine.computeDHash(uriString, 9)
    }

    private fun loadSystemThumbnail(uri: android.net.Uri): Bitmap? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val signal = CancellationSignal()
                context.contentResolver.loadThumbnail(uri, Size(32, 32), signal)
            } else {
                @Suppress("DEPRECATION")
                MediaStore.Images.Thumbnails.getThumbnail(
                    context.contentResolver,
                    ContentUris.parseId(uri),
                    MediaStore.Images.Thumbnails.MICRO_KIND,
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
