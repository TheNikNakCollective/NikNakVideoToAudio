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
      let m4aFileName = "\(UUID().uuidString).m4a"
      let wavFileName = "\(UUID().uuidString).wav"
      let m4aOutputURL = outputDirectory.appendingPathComponent(m4aFileName)
      let wavOutputURL = outputDirectory.appendingPathComponent(wavFileName)

      self.sendEvent(
        "log",
        [
          "m4a_output_url": m4aOutputURL.absoluteString,
          "wav_output_url": wavOutputURL.absoluteString,
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
      exporter.outputURL = m4aOutputURL

      exporter.exportAsynchronously {
        switch exporter.status {
        case .completed:
          self.sendEvent(
            "log", ["status": "Export completed", "m4a_file": m4aOutputURL.absoluteString])

          do {
            try self.convertM4AToWAV(inputURL: m4aOutputURL, outputURL: wavOutputURL)

            self.sendEvent(
              "log",
              ["status": "Conversion to WAV completed", "wav_file": wavOutputURL.absoluteString])

            promise.resolve([
              "output_file": wavOutputURL.absoluteString
            ])
          } catch {
            self.sendEvent(
              "log", ["error": "Failed to convert to WAV: \(error.localizedDescription)"])

            promise.reject(
              "CONVERSION_ERROR", "Failed to convert to WAV: \(error.localizedDescription)")
          }
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

  func convertM4AToWAV(inputURL: URL, outputURL: URL) throws {
    let audioFile = try AVAudioFile(forReading: inputURL)
      
    let format = AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: audioFile.fileFormat.sampleRate,
      channels: audioFile.fileFormat.channelCount,
      interleaved: true
    )!

    let outputFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)

    let buffer = AVAudioPCMBuffer(
      pcmFormat: audioFile.processingFormat,
      frameCapacity: AVAudioFrameCount(audioFile.length)
    )!
      
    try audioFile.read(into: buffer)

    try outputFile.write(from: buffer)
  }
}
