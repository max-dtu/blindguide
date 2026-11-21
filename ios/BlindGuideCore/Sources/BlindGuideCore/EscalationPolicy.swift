/// What the assistant should do with a question.
/// Implements the local-first rule in MVP.md: local inference by default,
/// cloud only when necessary, and always announced and declinable.
public enum EscalationDecision: Equatable, Sendable {
    /// Answer on the device (the default).
    case answerLocally
    /// Answer on the device, but tell the user it could not be confirmed.
    case answerLocallyWithUncertainty
    /// Ask the user before sending the frame or clip to the cloud.
    /// The app must announce this ("Checking with the cloud, one moment")
    /// and let the user decline.
    case askBeforeEscalating
}

public struct EscalationInput: Equatable, Sendable {
    public let localConfidence: Confidence
    /// The question needs knowledge the on-device model does not have.
    public let needsOutsideKnowledge: Bool
    /// The user explicitly asked for a second opinion.
    public let userRequestedSecondOpinion: Bool
    /// The user has allowed cloud escalation in settings.
    public let cloudEnabled: Bool

    public init(
        localConfidence: Confidence,
        needsOutsideKnowledge: Bool,
        userRequestedSecondOpinion: Bool,
        cloudEnabled: Bool
    ) {
        self.localConfidence = localConfidence
        self.needsOutsideKnowledge = needsOutsideKnowledge
        self.userRequestedSecondOpinion = userRequestedSecondOpinion
        self.cloudEnabled = cloudEnabled
    }
}

public enum EscalationPolicy {
    public static func decide(_ input: EscalationInput) -> EscalationDecision {
        let needsCloud = input.userRequestedSecondOpinion
            || input.needsOutsideKnowledge
            || input.localConfidence < HonestAnswer.minimumConfidence

        guard needsCloud else { return .answerLocally }

        // Cloud is needed but not allowed: answer locally and say it is uncertain.
        guard input.cloudEnabled else { return .answerLocallyWithUncertainty }

        return .askBeforeEscalating
    }
}
