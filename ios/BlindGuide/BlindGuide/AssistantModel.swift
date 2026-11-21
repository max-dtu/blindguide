import BlindGuideCore
import SwiftUI

/// Holds the user's settings and runs requests. Views talk only to this type.
@MainActor
final class AssistantModel: ObservableObject {
    @Published var verbosity: Verbosity = .normal
    @Published var cloudEnabled = false

    let speaker = Speaker()
    private let engine: VisionEngine

    init(engine: VisionEngine = PlaceholderVisionEngine()) {
        self.engine = engine
    }

    /// Runs a perception task and speaks the result honestly.
    func run(_ task: PerceptionTask) {
        Task {
            let answer = await engine.perform(task)
            let escalation = EscalationPolicy.decide(EscalationInput(
                localConfidence: answer.confidence,
                needsOutsideKnowledge: false,
                userRequestedSecondOpinion: false,
                cloudEnabled: cloudEnabled
            ))

            let text: String
            switch escalation {
            case .answerLocally, .answerLocallyWithUncertainty:
                text = HonestAnswer.render(answer)
            case .askBeforeEscalating:
                // Cloud escalation is not implemented yet. Never send anything silently.
                text = "I'm not sure. A cloud check would help, but it is not set up yet."
            }

            speaker.speak(
                SpeechRequest(text: text, priority: .userRequested, category: .answer),
                verbosity: verbosity
            )
        }
    }

    /// Speaks a safety alert. Safety alerts always interrupt other speech.
    func safetyAlert(_ text: String) {
        speaker.speak(
            SpeechRequest(text: text, priority: .safety, category: .safetyAlert),
            verbosity: verbosity
        )
    }
}
