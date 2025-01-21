import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import com.github.hiteshsondhi88.libffmpeg.FFmpeg
import com.github.hiteshsondhi88.libffmpeg.ExecuteBinaryResponseHandler
import android.util.Log
import java.io.File
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
            val outputFileName = "${UUID.randomUUID()}.mp3" // Change extension for desired format
            val outputFile = File(outputDirectory, outputFileName)

            sendEvent("log", mapOf("output_url" to outputFile.absolutePath))

            try {
                extractAudioWithFFmpeg(videoPath, outputFile.absolutePath) { success, message ->
                    if (success) {
                        promise.resolve(mapOf("output_file" to outputFile.absolutePath))
                    } else {
                        promise.reject("EXPORT_ERROR", message)
                    }
                }
            } catch (e: Exception) {
                Log.e("ExpoVideoToAudio", "Error extracting audio", e)
                promise.reject("EXPORT_ERROR", "Failed to extract audio: ${e.message}")
            }
        }
    }

    private fun extractAudioWithFFmpeg(inputPath: String, outputPath: String, callback: (Boolean, String?) -> Unit) {
        val ffmpeg = FFmpeg.getInstance(context)
        val command = arrayOf(
            "-i", inputPath, // Input file
            "-vn", // Exclude video stream
            "-acodec", "libmp3lame", // Encode as MP3
            "-q:a", "2", // Set quality (lower is better)
            outputPath // Output file
        )

        ffmpeg.execute(command, object : ExecuteBinaryResponseHandler() {
            override fun onStart() {
                Log.d("FFmpeg", "Started audio extraction")
                sendEvent("log", mapOf("status" to "started"))
            }

            override fun onProgress(message: String) {
                Log.d("FFmpeg", "Progress: $message")
                sendEvent("log", mapOf("progress" to message))
            }

            override fun onFailure(message: String) {
                Log.e("FFmpeg", "Failed with message: $message")
                callback(false, message)
            }

            override fun onSuccess(message: String) {
                Log.d("FFmpeg", "Success: $message")
                callback(true, null)
            }

            override fun onFinish() {
                Log.d("FFmpeg", "Finished processing")
                sendEvent("log", mapOf("status" to "finished"))
            }
        })
    }
}

data class VideoToAudioOptions(
    val videoPath: String
)
