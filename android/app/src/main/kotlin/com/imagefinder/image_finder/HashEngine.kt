package com.imagefinder.image_finder

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import java.io.ByteArrayOutputStream
import java.io.InputStream
import kotlin.math.PI
import kotlin.math.cos

/**
 * Native hash engine for fast exact (xxHash64) and perceptual (dHash / pHash) fingerprints.
 * All decode work uses sampled bitmaps — never full-resolution buffers for similarity.
 */
class HashEngine(private val context: Context) {

    fun computeContentHash(uriString: String): String {
        val uri = Uri.parse(uriString)
        val afd = context.contentResolver.openAssetFileDescriptor(uri, "r")
            ?: throw IllegalStateException("Unable to open uri: $uriString")
        afd.use { descriptor ->
            val length = descriptor.length
            val largeThreshold = 12L * 1024L * 1024L
            val window = 4L * 1024L * 1024L
            descriptor.createInputStream().use { input ->
                if (length < 0 || length <= largeThreshold) {
                    return xxHash64Stream(input).toULong().toString()
                }
                val start = readWindow(input, window)
                skipFully(input, (length / 2) - window)
                val mid = readWindow(input, window)
                skipFully(input, (length / 2) - (2 * window))
                val end = readWindow(input, window)
                val combined = ByteArray(start.size + mid.size + end.size + 8)
                var offset = 0
                start.copyInto(combined, offset); offset += start.size
                mid.copyInto(combined, offset); offset += mid.size
                end.copyInto(combined, offset); offset += end.size
                for (i in 0 until 8) {
                    combined[offset + i] = ((length ushr (8 * i)) and 0xFF).toByte()
                }
                return xxHash64(combined, 0L).toULong().toString()
            }
        }
    }

    private fun readWindow(input: InputStream, window: Long): ByteArray {
        val size = window.toInt()
        val out = ByteArrayOutputStream(size)
        val buf = ByteArray(64 * 1024)
        var remaining = size
        while (remaining > 0) {
            val n = input.read(buf, 0, minOf(buf.size, remaining))
            if (n < 0) break
            out.write(buf, 0, n)
            remaining -= n
        }
        return out.toByteArray()
    }

    private fun skipFully(input: InputStream, bytes: Long) {
        var left = bytes.coerceAtLeast(0)
        while (left > 0) {
            val skipped = input.skip(left)
            if (skipped > 0) {
                left -= skipped
                continue
            }
            val buf = ByteArray(minOf(64 * 1024L, left).toInt())
            val n = input.read(buf)
            if (n < 0) break
            left -= n
        }
    }

    fun computeDHash(uriString: String, targetSize: Int = 9): String {
        val bitmap = decodeSampled(uriString, 64, 64)
            ?: throw IllegalStateException("Unable to decode uri: $uriString")
        try {
            return dHashFromBitmap(bitmap)
        } finally {
            bitmap.recycle()
        }
    }

    fun computeDHashFromBytes(bytes: ByteArray): String {
        val opts = BitmapFactory.Options().apply {
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, opts)
            ?: throw IllegalStateException("Unable to decode thumbnail bytes")
        try {
            return dHashFromBitmap(bitmap)
        } finally {
            bitmap.recycle()
        }
    }

    private fun dHashFromBitmap(bitmap: Bitmap): String {
        val scaled = Bitmap.createScaledBitmap(bitmap, 9, 8, true)
        try {
            var hash = 0UL
            var bit = 0
            for (y in 0 until 8) {
                for (x in 0 until 8) {
                    val left = luminance(scaled.getPixel(x, y))
                    val right = luminance(scaled.getPixel(x + 1, y))
                    if (left > right) {
                        hash = hash or (1UL shl bit)
                    }
                    bit++
                }
            }
            return hash.toString()
        } finally {
            if (scaled !== bitmap) scaled.recycle()
        }
    }

    fun computePHash(uriString: String, targetSize: Int = 32): String {
        val size = targetSize.coerceAtLeast(32)
        val bitmap = decodeSampled(uriString, size, size)
            ?: throw IllegalStateException("Unable to decode uri: $uriString")
        try {
            return pHashFromBitmap(bitmap)
        } finally {
            bitmap.recycle()
        }
    }

    fun computePHashFromBytes(bytes: ByteArray): String {
        val opts = BitmapFactory.Options().apply {
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, opts)
            ?: throw IllegalStateException("Unable to decode thumbnail bytes")
        try {
            return pHashFromBitmap(bitmap)
        } finally {
            bitmap.recycle()
        }
    }

    private fun pHashFromBitmap(bitmap: Bitmap): String {
        val scaled = Bitmap.createScaledBitmap(bitmap, 32, 32, true)
        try {
            val gray = Array(32) { DoubleArray(32) }
            for (y in 0 until 32) {
                for (x in 0 until 32) {
                    gray[y][x] = luminance(scaled.getPixel(x, y))
                }
            }
            val dct = dct2D(gray)
            val values = ArrayList<Double>(63)
            for (y in 0 until 8) {
                for (x in 0 until 8) {
                    if (x == 0 && y == 0) continue
                    values.add(dct[y][x])
                }
            }
            val median = values.sorted()[values.size / 2]
            var hash = 0UL
            var bit = 0
            for (y in 0 until 8) {
                for (x in 0 until 8) {
                    if (dct[y][x] > median) {
                        hash = hash or (1UL shl bit)
                    }
                    bit++
                }
            }
            return hash.toString()
        } finally {
            if (scaled !== bitmap) scaled.recycle()
        }
    }

    private fun decodeSampled(uriString: String, reqWidth: Int, reqHeight: Int): Bitmap? {
        val uri = Uri.parse(uriString)
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        context.contentResolver.openInputStream(uri)?.use {
            BitmapFactory.decodeStream(it, null, bounds)
        } ?: return null

        val sample = calculateInSampleSize(bounds, reqWidth, reqHeight)
        val opts = BitmapFactory.Options().apply {
            inSampleSize = sample
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        return context.contentResolver.openInputStream(uri)?.use {
            BitmapFactory.decodeStream(it, null, opts)
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height, width) = options.outHeight to options.outWidth
        var inSampleSize = 1
        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize.coerceAtLeast(1)
    }

    private fun luminance(pixel: Int): Double {
        val r = Color.red(pixel)
        val g = Color.green(pixel)
        val b = Color.blue(pixel)
        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    private fun dct2D(input: Array<DoubleArray>): Array<DoubleArray> {
        val n = 32
        val output = Array(n) { DoubleArray(n) }
        for (u in 0 until n) {
            for (v in 0 until n) {
                var sum = 0.0
                for (x in 0 until n) {
                    for (y in 0 until n) {
                        sum += input[x][y] *
                            cos(((2 * x + 1) * u * PI) / (2.0 * n)) *
                            cos(((2 * y + 1) * v * PI) / (2.0 * n))
                    }
                }
                val cu = if (u == 0) 1.0 / kotlin.math.sqrt(2.0) else 1.0
                val cv = if (v == 0) 1.0 / kotlin.math.sqrt(2.0) else 1.0
                output[u][v] = 0.25 * cu * cv * sum
            }
        }
        return output
    }

    /** Buffering xxHash64 for files under the large-file threshold. */
    private fun xxHash64Stream(input: InputStream, seed: Long = 0L): Long {
        val buffered = input.buffered(64 * 1024)
        val out = ByteArrayOutputStream()
        val chunk = ByteArray(64 * 1024)
        var read: Int
        while (buffered.read(chunk).also { read = it } != -1) {
            out.write(chunk, 0, read)
        }
        return xxHash64(out.toByteArray(), seed)
    }

    private fun xxHash64(data: ByteArray, seed: Long): Long {
        val prime1 = -7046029288634856825L // 0x9E3779B185EBCA87
        val prime2 = -4417276706812531889L // 0xC2B2AE3D27D4EB4F
        val prime3 = 1609587929391213847L  // 0x165667B19E3779F9
        val prime4 = -8791301973928474373L // 0x85EBCA77C2B2AE63
        val prime5 = 2870177450012600261L  // 0x27D4EB2F165667C5

        var index = 0
        val length = data.size
        var hash: Long

        if (length >= 32) {
            var v1 = seed + prime1 + prime2
            var v2 = seed + prime2
            var v3 = seed
            var v4 = seed - prime1
            val limit = length - 32
            while (index <= limit) {
                v1 = round(v1, readLong(data, index)); index += 8
                v2 = round(v2, readLong(data, index)); index += 8
                v3 = round(v3, readLong(data, index)); index += 8
                v4 = round(v4, readLong(data, index)); index += 8
            }
            hash = rotateLeft(v1, 1) + rotateLeft(v2, 7) + rotateLeft(v3, 12) + rotateLeft(v4, 18)
            hash = mergeRound(hash, v1)
            hash = mergeRound(hash, v2)
            hash = mergeRound(hash, v3)
            hash = mergeRound(hash, v4)
        } else {
            hash = seed + prime5
        }

        hash += length.toLong()

        while (index + 8 <= length) {
            val k1 = round(0, readLong(data, index))
            hash = rotateLeft(hash xor k1, 27) * prime1 + prime4
            index += 8
        }
        if (index + 4 <= length) {
            hash = rotateLeft(
                hash xor (readInt(data, index).toLong() and 0xFFFFFFFFL) * prime1,
                23,
            ) * prime2 + prime3
            index += 4
        }
        while (index < length) {
            hash = rotateLeft(hash xor ((data[index].toLong() and 0xFF) * prime5), 11) * prime1
            index++
        }

        hash = hash xor (hash ushr 33)
        hash *= prime2
        hash = hash xor (hash ushr 29)
        hash *= prime3
        hash = hash xor (hash ushr 32)
        return hash
    }

    private fun round(acc: Long, input: Long): Long {
        val prime1 = -7046029288634856825L
        val prime2 = -4417276706812531889L
        var a = acc + input * prime2
        a = rotateLeft(a, 31)
        return a * prime1
    }

    private fun mergeRound(acc: Long, value: Long): Long {
        val prime1 = -7046029288634856825L
        val prime4 = -8791301973928474373L
        return (acc xor round(0, value)) * prime1 + prime4
    }

    private fun rotateLeft(value: Long, bits: Int): Long =
        (value shl bits) or (value ushr (64 - bits))

    private fun readLong(data: ByteArray, offset: Int): Long {
        var v = 0L
        for (i in 0 until 8) {
            v = v or ((data[offset + i].toLong() and 0xFF) shl (8 * i))
        }
        return v
    }

    private fun readInt(data: ByteArray, offset: Int): Int {
        var v = 0
        for (i in 0 until 4) {
            v = v or ((data[offset + i].toInt() and 0xFF) shl (8 * i))
        }
        return v
    }
}
