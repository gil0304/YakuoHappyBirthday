import AVFoundation
import Foundation
import UIKit

final class AudioManager: NSObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    private var player: AVAudioPlayer?
    private var onFinish: (() -> Void)?
    private let synthesizer = AVSpeechSynthesizer()
    private var ttsTask: URLSessionDataTask?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    @discardableResult
    func play(fileName: String, onFinish: (() -> Void)?) -> Bool {
        stop()

        let (name, ext) = splitFileName(fileName)
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return play(url: url, onFinish: onFinish)
        }

        if let asset = NSDataAsset(name: fileName) ?? NSDataAsset(name: name) {
            return play(data: asset.data, onFinish: onFinish)
        }

        return false
    }

    func playOrSpeak(fileName: String, fallbackText: String, localeIdentifier: String, onFinish: (() -> Void)?) {
        if !play(fileName: fileName, onFinish: onFinish) {
            speakWithGoogleOrApple(text: fallbackText, localeIdentifier: localeIdentifier, onFinish: onFinish)
        }
    }

    func speak(text: String, localeIdentifier: String, onFinish: (() -> Void)?) {
        stop()
        self.onFinish = onFinish
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: localeIdentifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }

    func stop() {
        ttsTask?.cancel()
        ttsTask = nil
        player?.stop()
        player = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        onFinish = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let callback = onFinish
        onFinish = nil
        DispatchQueue.main.async {
            callback?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let callback = onFinish
        onFinish = nil
        DispatchQueue.main.async {
            callback?()
        }
    }

    private func speakWithGoogleOrApple(text: String, localeIdentifier: String, onFinish: (() -> Void)?) {
        if GoogleTTSConfig.apiKey.isEmpty {
            speak(text: text, localeIdentifier: localeIdentifier, onFinish: onFinish)
            return
        }

        fetchGoogleTTSAudio(text: text) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                if !self.play(data: data, onFinish: onFinish) {
                    self.speak(text: text, localeIdentifier: localeIdentifier, onFinish: onFinish)
                }
            case .failure:
                self.speak(text: text, localeIdentifier: localeIdentifier, onFinish: onFinish)
            }
        }
    }

    private func fetchGoogleTTSAudio(text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(GoogleTTSConfig.apiKey)") else {
            completion(.failure(NSError(domain: "GoogleTTS", code: -1)))
            return
        }

        let body: [String: Any] = [
            "input": ["text": text],
            "voice": [
                "languageCode": GoogleTTSConfig.languageCode,
                "ssmlGender": GoogleTTSConfig.ssmlGender
            ],
            "audioConfig": [
                "audioEncoding": GoogleTTSConfig.audioEncoding
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        ttsTask?.cancel()
        ttsTask = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data,
                  let response = try? JSONDecoder().decode(GoogleTTSResponse.self, from: data),
                  let audioData = Data(base64Encoded: response.audioContent)
            else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "GoogleTTS", code: -2)))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(audioData))
            }
        }
        ttsTask?.resume()
    }

    private func play(url: URL, onFinish: (() -> Void)?) -> Bool {
        do {
            self.onFinish = onFinish
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
            return true
        } catch {
            return false
        }
    }

    private func play(data: Data, onFinish: (() -> Void)?) -> Bool {
        do {
            self.onFinish = onFinish
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
            return true
        } catch {
            return false
        }
    }

    private func splitFileName(_ fileName: String) -> (String, String?) {
        guard let dotIndex = fileName.lastIndex(of: ".") else {
            return (fileName, nil)
        }
        let name = String(fileName[..<dotIndex])
        let ext = String(fileName[fileName.index(after: dotIndex)...])
        return (name, ext.isEmpty ? nil : ext)
    }
}

private struct GoogleTTSResponse: Decodable {
    let audioContent: String
}
