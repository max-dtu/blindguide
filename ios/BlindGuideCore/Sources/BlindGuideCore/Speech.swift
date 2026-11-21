/// Priority of a spoken message. Story 5.3: safety alerts interrupt any ongoing speech.
public enum SpeechPriority: Int, Comparable, Sendable {
    case ambient = 0
    case userRequested = 1
    case safety = 2

    public static func < (lhs: SpeechPriority, rhs: SpeechPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct SpeechRequest: Equatable, Sendable {
    public let text: String
    public let priority: SpeechPriority
    public let category: SpeechCategory

    public init(text: String, priority: SpeechPriority, category: SpeechCategory) {
        self.text = text
        self.priority = priority
        self.category = category
    }
}

/// Decides what happens to a new message given what is currently being spoken.
public enum InterruptDecision: Equatable, Sendable {
    /// Stop current speech and speak the new message now.
    case interruptAndSpeak
    /// Queue the new message after the current speech.
    case enqueue
    /// Drop the new message (verbosity forbids it).
    case drop
}

public enum SpeechArbiter {
    /// Applies verbosity first, then priority.
    /// - Parameters:
    ///   - request: the message to speak.
    ///   - verbosity: the user's current verbosity setting.
    ///   - currentPriority: priority of the message being spoken now, or nil if silent.
    public static func decide(
        for request: SpeechRequest,
        verbosity: Verbosity,
        currentPriority: SpeechPriority?
    ) -> InterruptDecision {
        guard verbosity.allows(request.category) else { return .drop }
        guard let current = currentPriority else { return .enqueue }
        if request.priority == .safety && current != .safety {
            return .interruptAndSpeak
        }
        return .enqueue
    }
}
