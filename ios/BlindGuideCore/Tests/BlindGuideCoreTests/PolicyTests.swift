import XCTest
@testable import BlindGuideCore

final class VerbosityTests: XCTestCase {
    func testSilentSpeaksNothing() {
        for category in [SpeechCategory.safetyAlert, .answer, .unsolicitedDetail] {
            XCTAssertFalse(Verbosity.silent.allows(category))
        }
    }

    func testAlertsOnlySpeaksOnlySafetyAlerts() {
        XCTAssertTrue(Verbosity.alertsOnly.allows(.safetyAlert))
        XCTAssertFalse(Verbosity.alertsOnly.allows(.answer))
        XCTAssertFalse(Verbosity.alertsOnly.allows(.unsolicitedDetail))
    }

    func testNormalSpeaksAlertsAndAnswersButNotDetail() {
        XCTAssertTrue(Verbosity.normal.allows(.safetyAlert))
        XCTAssertTrue(Verbosity.normal.allows(.answer))
        XCTAssertFalse(Verbosity.normal.allows(.unsolicitedDetail))
    }

    func testDescriptiveSpeaksEverything() {
        for category in [SpeechCategory.safetyAlert, .answer, .unsolicitedDetail] {
            XCTAssertTrue(Verbosity.descriptive.allows(category))
        }
    }

    func testLevelsAreOrderedFromQuietestToChattiest() {
        XCTAssertLessThan(Verbosity.silent, Verbosity.alertsOnly)
        XCTAssertLessThan(Verbosity.alertsOnly, Verbosity.normal)
        XCTAssertLessThan(Verbosity.normal, Verbosity.descriptive)
    }
}

final class SpeechArbiterTests: XCTestCase {
    func testSafetyAlertInterruptsUserSpeech() {
        let alert = SpeechRequest(text: "Pole, slightly left", priority: .safety, category: .safetyAlert)
        let decision = SpeechArbiter.decide(for: alert, verbosity: .normal, currentPriority: .userRequested)
        XCTAssertEqual(decision, .interruptAndSpeak)
    }

    func testSafetyAlertDoesNotInterruptAnotherSafetyAlert() {
        let alert = SpeechRequest(text: "Step down ahead", priority: .safety, category: .safetyAlert)
        let decision = SpeechArbiter.decide(for: alert, verbosity: .normal, currentPriority: .safety)
        XCTAssertEqual(decision, .enqueue)
    }

    func testOrdinaryAnswerQueuesBehindCurrentSpeech() {
        let answer = SpeechRequest(text: "A bakery sign", priority: .userRequested, category: .answer)
        let decision = SpeechArbiter.decide(for: answer, verbosity: .normal, currentPriority: .userRequested)
        XCTAssertEqual(decision, .enqueue)
    }

    func testVerbosityDropsMessagesBeforePriorityIsConsidered() {
        let detail = SpeechRequest(text: "The sky is blue", priority: .ambient, category: .unsolicitedDetail)
        XCTAssertEqual(SpeechArbiter.decide(for: detail, verbosity: .normal, currentPriority: nil), .drop)
    }

    func testSilentModeDropsEvenSafetyAlerts() {
        let alert = SpeechRequest(text: "Pole", priority: .safety, category: .safetyAlert)
        XCTAssertEqual(SpeechArbiter.decide(for: alert, verbosity: .silent, currentPriority: nil), .drop)
    }
}

final class HonestAnswerTests: XCTestCase {
    func testConfidentAnswerIsStatedPlainly() {
        let answer = Answer(text: "Walk signal on", confidence: Confidence(0.95))
        XCTAssertEqual(HonestAnswer.render(answer), "Walk signal on")
    }

    func testLowConfidenceAnswerIsPrefixedWithUncertainty() {
        let answer = Answer(text: "Ibuprofen 200 mg", confidence: Confidence(0.4))
        XCTAssertEqual(HonestAnswer.render(answer), "I'm not sure. It might be: Ibuprofen 200 mg")
    }

    func testConfidenceIsClampedToUnitRange() {
        XCTAssertEqual(Confidence(1.7).value, 1.0)
        XCTAssertEqual(Confidence(-0.3).value, 0.0)
    }

    func testThresholdBoundaryIsConfident() {
        let answer = Answer(text: "Door", confidence: HonestAnswer.minimumConfidence)
        XCTAssertEqual(HonestAnswer.render(answer), "Door")
    }
}

final class EscalationPolicyTests: XCTestCase {
    private func input(
        confidence: Double = 0.9,
        outsideKnowledge: Bool = false,
        secondOpinion: Bool = false,
        cloudEnabled: Bool = true
    ) -> EscalationInput {
        EscalationInput(
            localConfidence: Confidence(confidence),
            needsOutsideKnowledge: outsideKnowledge,
            userRequestedSecondOpinion: secondOpinion,
            cloudEnabled: cloudEnabled
        )
    }

    func testConfidentLocalAnswerNeverEscalates() {
        XCTAssertEqual(EscalationPolicy.decide(input()), .answerLocally)
    }

    func testLowConfidenceAsksBeforeEscalating() {
        XCTAssertEqual(EscalationPolicy.decide(input(confidence: 0.3)), .askBeforeEscalating)
    }

    func testOutsideKnowledgeAsksBeforeEscalating() {
        XCTAssertEqual(EscalationPolicy.decide(input(outsideKnowledge: true)), .askBeforeEscalating)
    }

    func testUserSecondOpinionAsksBeforeEscalating() {
        XCTAssertEqual(EscalationPolicy.decide(input(secondOpinion: true)), .askBeforeEscalating)
    }

    func testCloudDisabledNeverEscalatesAndAdmitsUncertainty() {
        let decision = EscalationPolicy.decide(input(confidence: 0.2, cloudEnabled: false))
        XCTAssertEqual(decision, .answerLocallyWithUncertainty)
    }
}
