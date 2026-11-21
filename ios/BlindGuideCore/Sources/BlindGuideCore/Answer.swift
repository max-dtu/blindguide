/// Confidence reported by a model for one answer, in the range 0...1.
public struct Confidence: Equatable, Comparable, Sendable {
    public let value: Double

    /// Clamps the input into 0...1.
    public init(_ value: Double) {
        self.value = min(max(value, 0), 1)
    }

    public static func < (lhs: Confidence, rhs: Confidence) -> Bool {
        lhs.value < rhs.value
    }
}

/// An answer produced by a perception or reasoning step.
public struct Answer: Equatable, Sendable {
    public let text: String
    public let confidence: Confidence

    public init(text: String, confidence: Confidence) {
        self.text = text
        self.confidence = confidence
    }
}

public enum HonestAnswer {
    /// Minimum confidence before the assistant states an answer as fact.
    /// Below this, the answer is prefixed with uncertainty. Story 5.5.
    public static let minimumConfidence = Confidence(0.7)

    /// Returns the text to speak. Never guesses: low-confidence answers are
    /// prefixed with "I'm not sure", and the answer itself is still offered.
    public static func render(_ answer: Answer, threshold: Confidence = minimumConfidence) -> String {
        if answer.confidence < threshold {
            return "I'm not sure. It might be: \(answer.text)"
        }
        return answer.text
    }

    /// The fallback when no answer can be produced at all.
    public static let cannotSeeMessage = "I can't tell from here. Try moving closer, or check the light."
}
