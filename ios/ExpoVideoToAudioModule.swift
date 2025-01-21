import AVFoundation
import ExpoModulesCore

public class ExpoVideoToAudioModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoVideoToAudio")

    Events("log")

    AsyncFunction("extractAudio") { (options: ExpoVideoToAudioOptions, promise: Promise) in
      let videoURL = URL(string: options.videoPath)!

      let outputDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        .first!
      let outputFileName = "\(UUID().uuidString).m4a"
      let outputURL = outputDirectory.appendingPathComponent(outputFileName)

      self.sendEvent(
        "log",
        [
          "output_url": outputURL.absoluteString
        ])

      let asset = AVAsset(url: videoURL)

      self.sendEvent(
        "log",
        [
          "video_url": videoURL.absoluteString
        ])

      guard
        let exporter = AVAssetExportSession(
            asset: asset, presetName: AVAssetExportPresetAppleM4A)
      else {
        promise.reject("EXPORT_ERROR", "Failed to initialize exporter")
        return
      }

      if !exporter.supportedFileTypes.contains(.m4a) {
        promise.reject("UNSUPPORTED_FORMAT", "The MP3 format is not supported for this asset")
        return
      }

      self.sendEvent(
        "log",
        [
          "supported_file_types": exporter.supportedFileTypes.map { $0.rawValue }
        ])

      exporter.outputFileType = .m4a
      exporter.outputURL = outputURL

      exporter.exportAsynchronously {
        switch exporter.status {
        case .completed:
          promise.resolve([
            "output_file": outputURL.absoluteString
          ])
        case .failed:
          self.sendEvent("log", ["error": exporter.error?.localizedDescription ?? "Unknown error"])
          promise.reject(
            "EXPORT_ERROR",
            "Failed to extract audio: \(exporter.error?.localizedDescription ?? "Unknown error")")
        case .cancelled:
          self.sendEvent("log", ["status": "cancelled"])
          promise.reject("EXPORT_CANCELLED", "Audio extraction was cancelled.")
        default:
          self.sendEvent("log", ["status": "\(exporter.status.rawValue)"])
          promise.reject(
            "EXPORT_ERROR", "Audio extraction failed with status: \(exporter.status.rawValue)")
        }
      }
    }
  }
}
