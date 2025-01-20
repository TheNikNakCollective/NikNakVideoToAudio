import ExpoModulesCore
import AVFoundation

public class ExpoVideoToAudioModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoVideoToAudio")
    
    Function("extractAudio") { (videoPath: String, outputPath: String, promise: Promise) in
      let videoURL = URL(fileURLWithPath: videoPath)
      let outputURL = URL(fileURLWithPath: outputPath)

      let asset = AVAsset(url: videoURL)
      guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
        promise.reject("EXPORT_ERROR", "Failed to initialize exporter")
        return
      }

      exporter.outputFileType = .m4a
      exporter.outputURL = outputURL
      exporter.exportAsynchronously {
        if exporter.status == .completed {
          promise.resolve("Audio extracted successfully at: \(outputPath)")
        } else {
          promise.reject("EXPORT_ERROR", "Failed to extract audio: \(exporter.error?.localizedDescription ?? "Unknown error")")
        }
      }
    }
  }
}
