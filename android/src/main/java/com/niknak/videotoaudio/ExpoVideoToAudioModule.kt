package com.niknak.videotoaudio

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import com.arthenica.mobileffmpeg.FFmpeg
import expo.modules.kotlin.promise.Promise

class ExpoVideoToAudioModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("ExpoVideoToAudio") // Name of the module

        Function("extractAudio") { videoPath: String, outputPath: String, promise: Promise ->
            // Use FFmpeg to extract audio
            val command = "-i $videoPath -q:a 0 -map a $outputPath"
            val result = FFmpeg.execute(command)

            if (result == 0) {
                // Success
                promise.resolve("Audio extracted successfully at: $outputPath")
            } else {
                // Failure
                promise.reject("AUDIO_EXTRACTION_FAILED", "Failed to extract audio with FFmpeg")
            }
        }
    }
}
