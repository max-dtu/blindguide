# BlindGuide iOS

The iOS app is the first target (see [MVP.md](../MVP.md)). It is split in two:

- **`BlindGuideCore/`**: a Swift package with platform-neutral MVP rules. It has no UI, camera or audio code. It holds the decisions that must be the same on every platform: verbosity (story 5.2), speech priority and interruption (5.3), honest answers (5.5), and local-first escalation (MVP.md, Design rules).
- **`BlindGuide/`** (to be created in Xcode): the SwiftUI app. It handles the camera, microphone, speech, haptics, VoiceOver, and the on-device models. It depends on `BlindGuideCore`.

## Status

- `BlindGuideCore` builds with `swift build`.
- Its policy checks pass when run against the sources directly.
- The XCTest suite in `BlindGuideCore/Tests/` is written but has not been run here, because this machine has only the Command Line Tools and not full Xcode. Run it with `swift test` in Xcode or on a machine with full Xcode installed.
- `BlindGuide/BlindGuide/` contains the SwiftUI app sources. They compile against `BlindGuideCore` with the macOS SDK in Swift 5 and Swift 6 modes. They have not been built for iOS or run on a device.
- The app has a voice-ready screen with the perception actions, a verbosity setting, a cloud toggle, and a "Call a human" placeholder. Perception returns "I'm not sure" until an on-device model is connected (`VisionEngine.swift`).
- `BlindGuide/project.yml` is an XcodeGen spec. `BlindGuide/BlindGuide.xcodeproj` is generated from it and is committed so the project opens directly. Regenerate it after changing `project.yml`.
- The project references `BlindGuideCore` by relative path. It has not been compiled with the iOS SDK, because this machine has no full Xcode.

## Set up the app target (needs full Xcode)

Option A, XcodeGen (recommended, keeps the project file generated from `project.yml`):

```bash
brew install xcodegen
cd ios/BlindGuide
xcodegen generate
open BlindGuide.xcodeproj
```

Option B, manual Xcode setup:

1. Open Xcode and choose **File > New > Project > iOS > App**. Use SwiftUI, Swift, and product name `BlindGuide`. Save it in `ios/BlindGuide/`.
2. Replace the generated files with the sources in `ios/BlindGuide/BlindGuide/`.
3. Choose **File > Add Package Dependencies > Add Local**, select `ios/BlindGuideCore`, and add the `BlindGuideCore` product to the app target.
4. Add the camera and microphone usage descriptions from `project.yml` to the target's Info settings.
5. Enable **Accessibility** checks and test with VoiceOver on every screen.
6. Set the minimum iOS version. This is an open question in MVP.md. `project.yml` uses iOS 17.

## Run the core tests

```bash
cd ios/BlindGuideCore
swift test
```

Expected result with full Xcode: all tests in `PolicyTests.swift` pass.
