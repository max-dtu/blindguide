import XCTest

/// Launches the app in the simulator and checks the main controls are present.
/// Runs in CI on a macOS runner with Xcode (see .github/workflows/ios.yml).
final class LaunchTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsMainActions() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["BlindGuide"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Read text"].exists)
        XCTAssertTrue(app.buttons["What is this?"].exists)
        XCTAssertTrue(app.buttons["What's around me?"].exists)
        XCTAssertTrue(app.buttons["Call a human"].exists)
    }

    /// Runs Apple's accessibility audit on the main screen (iOS 17+).
    /// It flags missing labels, small tap targets, contrast and clipping problems.
    func testMainScreenPassesAccessibilityAudit() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Read text"].waitForExistence(timeout: 10))
        try app.performAccessibilityAudit()
    }

    func testReadTextActionDoesNotCrash() throws {
        let app = XCUIApplication()
        app.launch()

        let readText = app.buttons["Read text"]
        XCTAssertTrue(readText.waitForExistence(timeout: 10))
        readText.tap()

        // The placeholder engine answers "I'm not sure", so the app stays on its main screen.
        XCTAssertTrue(app.navigationBars["BlindGuide"].exists)
    }
}
