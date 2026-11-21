# BlindGuide iOS

The iOS app is the first target (see [MVP.md](../MVP.md)). It is split in two:

- **`BlindGuideCore/`**: a Swift package with platform-neutral MVP rules. It has no UI, camera or audio code. It holds the decisions that must be the same on every platform: verbosity (story 5.2), speech priority and interruption (5.3), honest answers (5.5), and local-first escalation (MVP.md, Design rules).
- **`BlindGuide/`** (to be created in Xcode): the SwiftUI app. It handles the camera, microphone, speech, haptics, VoiceOver, and the on-device models. It depends on `BlindGuideCore`.

## Status

- `BlindGuideCore` builds with `swift build`.
- Its policy checks pass when run against the sources directly.
- The XCTest suite in `BlindGuideCore/Tests/` is written but has not been run here, because this machine has only the Command Line Tools and not full Xcode. Run it with `swift test` in Xcode or on a machine with full Xcode installed.
- The SwiftUI app target does not exist yet.

## Set up the app target (needs full Xcode)

1. Open Xcode and choose **File > New > Project > iOS > App**. Use SwiftUI, Swift, and product name `BlindGuide`. Save it in `ios/`.
2. Choose **File > Add Package Dependencies > Add Local**, select `ios/BlindGuideCore`, and add the `BlindGuideCore` product to the app target.
3. Enable **Accessibility** checks and test with VoiceOver on every screen.
4. Set the minimum iOS version. This is an open question in MVP.md.

## Run the core tests

```bash
cd ios/BlindGuideCore
swift test
```

Expected result with full Xcode: all tests in `PolicyTests.swift` pass.
