import AVFoundation
import BlindGuideCore

/// Speaks messages through AVSpeechSynthesizer, applying the shared rules
/// from BlindGuideCore: verbosity filters what may be said, and safety alerts
/// interrupt other speech (stories 5.2 and 5.3).
@MainActor
final class Speaker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var currentPriority: SpeechPriority?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ request: SpeechRequest, verbosity: Verbosity) {
        let decision = SpeechArbiter.decide(
            for: request,
            verbosity: verbosity,
            currentPriority: synthesizer.isSpeaking ? currentPriority : nil
        )

        switch decision {
        case .drop:
            return
        case .interruptAndSpeak:
            synthesizer.stopSpeaking(at: .immediate)
            enqueue(request)
        case .enqueue:
            enqueue(request)
        }
    }

    private func enqueue(_ request: SpeechRequest) {
        let utterance = AVSpeechUtterance(string: request.text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
        currentPriority = request.priority
        synthesizer.speak(utterance)
    }
}
