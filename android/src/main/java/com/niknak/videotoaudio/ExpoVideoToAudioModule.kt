import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.util.Log
import java.io.File
import java.io.IOException
import java.util.UUID

class ExpoVideoToAudioModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("ExpoVideoToAudio")

        Events("log")

        AsyncFunction("extractAudio") { options: VideoToAudioOptions, promise: Promise ->
            val videoPath = options.videoPath
            val videoFile = File(videoPath)

            if (!videoFile.exists()) {
                promise.reject("FILE_NOT_FOUND", "The video file does not exist at path: $videoPath")
                return@AsyncFunction
            }

            val outputDirectory = context.cacheDir
            val outputFileName = "${UUID.randomUUID()}.wav"
            val outputFile = File(outputDirectory, outputFileName)

            sendEvent("log", mapOf("output_url" to outputFile.absolutePath))

            try {
                extractAudio(videoPath, outputFile.absolutePath)
                promise.resolve(mapOf("output_file" to outputFile.absolutePath))
            } catch (e: IOException) {
                Log.e("ExpoVideoToAudio", "Error extracting audio", e)
                promise.reject("EXPORT_ERROR", "Failed to extract audio: ${e.message}")
            }
        }
    }

    private fun extractAudio(inputPath: String, outputPath: String) {
        val extractor = MediaExtractor()
        extractor.setDataSource(inputPath)

        val audioTrackIndex = (0 until extractor.trackCount).firstOrNull { index ->
            val format = extractor.getTrackFormat(index)
            val mime = format.getString(MediaFormat.KEY_MIME)
            mime?.startsWith("audio/") == true
        } ?: throw IOException("No audio track found in the video file.")

        extractor.selectTrack(audioTrackIndex)
        val format = extractor.getTrackFormat(audioTrackIndex)

        val muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4) // WAV-like handling
        val outputTrackIndex = muxer.addTrack(format)

        muxer.start()

        val buffer = ByteArray(1024 * 1024) // 1 MB buffer
        val byteBuffer = java.nio.ByteBuffer.wrap(buffer)
        val bufferInfo = android.media.MediaCodec.BufferInfo()

        while (true) {
            val sampleSize = extractor.readSampleData(byteBuffer, 0)
            if (sampleSize < 0) break

            bufferInfo.size = sampleSize
            bufferInfo.offset = 0
            bufferInfo.presentationTimeUs = extractor.sampleTime
            bufferInfo.flags = extractor.sampleFlags

            muxer.writeSampleData(outputTrackIndex, byteBuffer, bufferInfo)
            extractor.advance()
        }

        muxer.stop()
        muxer.release()
        extractor.release()
    }
}

data class VideoToAudioOptions(
    val videoPath: String
)
