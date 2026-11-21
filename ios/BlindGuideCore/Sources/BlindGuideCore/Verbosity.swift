/// How chatty the assistant is. Story 5.2.
/// Ordered from least to most speech.
public enum Verbosity: Int, CaseIterable, Comparable, Sendable {
    case silent = 0
    case alertsOnly = 1
    case normal = 2
    case descriptive = 3

    public static func < (lhs: Verbosity, rhs: Verbosity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Categories of spoken output, used to decide whether a verbosity level allows it.
public enum SpeechCategory: Sendable {
    /// Obstacle and crossing warnings (story 1.1, 1.2). Always allowed unless silent.
    case safetyAlert
    /// Direct answers to the user's own request (text, object, scene).
    case answer
    /// Extra detail the user did not ask for.
    case unsolicitedDetail
}

extension Verbosity {
    /// Whether this verbosity level allows speech of the given category.
    ///
    /// In silent mode nothing is spoken. Safety alerts still reach the user as
    /// haptic or tone cues (story 1.1 quiet mode), which the audio layer handles.
    /// This function only answers "may we speak it?".
    public func allows(_ category: SpeechCategory) -> Bool {
        switch (self, category) {
        case (.silent, _):
            return false
        case (.alertsOnly, .safetyAlert):
            return true
        case (.alertsOnly, _):
            return false
        case (.normal, .safetyAlert), (.normal, .answer):
            return true
        case (.normal, .unsolicitedDetail):
            return false
        case (.descriptive, _):
            return true
        }
    }
}
