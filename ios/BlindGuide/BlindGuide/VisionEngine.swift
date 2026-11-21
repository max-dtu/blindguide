import BlindGuideCore

/// A request that needs perception (text, object, or scene).
enum PerceptionTask: String, CaseIterable, Identifiable {
    case readText = "Read text"
    case whatIsThis = "What is this?"
    case describeScene = "What's around me?"

    var id: String { rawValue }
}

/// On-device perception. The real implementation (vision and OCR models) comes later.
/// Local inference is the default. See MVP.md, "Design rules".
protocol VisionEngine: Sendable {
    func perform(_ task: PerceptionTask) async -> Answer
}

/// Placeholder engine used until on-device models are integrated.
/// It never claims a result: it returns zero confidence, so the answer
/// is spoken as "I'm not sure" through HonestAnswer. This keeps the
/// honesty rule (story 5.5) true even before models exist.
struct PlaceholderVisionEngine: VisionEngine {
    func perform(_ task: PerceptionTask) async -> Answer {
        Answer(text: "the on-device model is not connected yet", confidence: Confidence(0))
    }
}
