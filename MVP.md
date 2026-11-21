# BlindGuide – MVP

This document defines the first release of BlindGuide. It is scoped from [USER_STORIES.md](USER_STORIES.md). Story IDs refer to that file.

## Goal
Prove that an audio-first assistant can help a blind or low-vision person with everyday tasks, safely and honestly, on the devices people already own. The MVP succeeds if real users in co-design and field tests can complete the core tasks and say they trust the assistant more than they distrust it.

## Supported devices

The MVP targets **web first**, then iOS, then Android and Meta glasses. The phone (or browser device) is the compute hub. Glasses are a peripheral that provides camera, microphone and audio.

| Configuration | Camera | Microphone | Audio out | Status |
|---|---|---|---|---|
| **Web app** (first target) | Device camera via browser | Device mic via browser | Device speaker, headphones | **MVP, first** |
| **iPhone** | Phone camera | Phone mic | Phone speaker, headphones, or bone conduction / open-ear | Next (after web) |
| **Android phone** | Phone camera | Phone mic | Phone speaker, headphones, or bone conduction / open-ear | Post-MVP |
| **Meta smart glasses** | Glasses camera (via phone companion link) | Glasses mic | Glasses open-ear speakers | Post-MVP |

Notes:
- **Web first:** the web app runs in a browser on any device, so it is the fastest way to test the shared rules with real users. It must work fully with a screen reader and keyboard, and pass automated accessibility checks in CI.
- **iOS next:** the primary user (Maya) uses VoiceOver on an iPhone, so the iOS app is the reference for VoiceOver behavior. It must work fully with VoiceOver. The iOS app work already committed is paused, and its failing accessibility check (Dynamic Type on the settings toggle) is open.
- **Android** (after iOS) must support TalkBack. The shared core should be kept platform-neutral so this is an adapter job, not a rewrite.
- **Meta glasses** (after Android): the phone runs the app and connects to the glasses through the vendor's device SDK. Glasses-specific input (tap, voice) maps to the same commands as the phone. The glasses SDK's exact capabilities (camera frame rate, streaming latency, mic access) must be verified before that milestone.
- **Other devices** (other smart glasses, watches, dedicated hardware) are out of scope.

## Architecture (MVP level)

```
 Camera / mic / speaker / haptics
   (phone, or Meta glasses via SDK)
                │
        ┌───────▼────────┐
        │ Device adapter │  one per platform: iOS, Android, Meta glasses
        └───────┬────────┘
                │ frames, audio, events
   ┌────────────▼─────────────┐
   │ Shared core               │
   │  - Safety layer (on-device) │  obstacle / crossing alerts, latency-critical
   │  - Interaction (voice, verbosity, interruption)
   │  - On-device inference (default for scene, text, object)
   │  - Cloud escalation (only when necessary, see below)
   │  - Privacy controls (no storage by default)
   └────────────┬─────────────┘
                │
        Accessibility layer: VoiceOver (iOS), TalkBack (Android)
```

Design rules:
1. **Local inference first.** All perception (text reading, object identification, scene description) runs on the device by default. Images and audio leave the phone only when local inference cannot answer and the user allows it.
2. **Cloud only when necessary.** Escalate to cloud only when: the local model reports low confidence, the task needs knowledge the local model lacks, or the user explicitly asks for a second opinion. Every escalation is announced ("Checking with the cloud, one moment") and can be declined. Cloud requests send only the frame or clip needed for the question, never a stream.
3. **Safety alerts never depend on the network.** They run on the phone, under the latency target (300 ms).
4. **Device differences stay in the adapter.** The core logic, prompts, verbosity rules and privacy rules are the same on every platform.
5. **Everything works without the screen.** No feature may require visual UI as its only path.
6. **Offline core.** Safety alerts, text reading and object identification must work with no network at all.

## MVP scope

### In the MVP

| Story | Feature | Notes |
|---|---|---|
| 2.1 | Instant text reading | Summarize first, read in full on request. |
| 3.1 | What is this? | Says "I'm not sure" when unclear. |
| 4.3 | Scene description | Short first, "Tell me more" for detail. |
| 5.1 | Hands-free voice | Voice and a single tap (phone button or glasses tap). |
| 5.2 | Verbosity control | Silent / alerts only / normal / descriptive. |
| 5.3 | Priority interruption | Safety alerts interrupt any speech. |
| 5.5 | Honest uncertainty | Required in every answer path. |
| 6.1 | Call a human | Shares the live view with a contact. |
| 6.4 | Battery and offline awareness | Warns about low battery and lost connection. Safety alerts keep working offline. |
| 6.5 | Privacy | Video only while in use. No recordings stored unless the user opts in. Bystander faces not saved. |
| 7.3 | Voice-guided onboarding | Setup with no visual steps. |
| 1.1 | Obstacle warnings | **Coarse** alerts only: presence, direction, rough distance. Gated on field testing. |
| 1.2 | Crossing | **Reports signal state only** ("Walk signal on", "Don't walk", "I can't see a signal"). Never says "safe to cross." Gated on field testing. |

### Deferred (not in the MVP)

| Story | Reason |
|---|---|
| 3.2 Medication | A misread dose can cause harm. Needs labelled-sample accuracy testing first. |
| 3.4 Money | Errors cause financial harm. Needs accuracy testing first. |
| 1.3 Turn-by-turn directions | Needs mapping, GPS fusion and landmark recognition. |
| 2.2 Bills | Useful but not essential to the core test. |
| 1.4, 1.5, 1.6, 1.7 | Later navigation work. |
| 2.3, 2.4, 2.5 | Later reading work. |
| 3.3, 3.5–3.8 | Later object and everyday tasks. |
| 4.1, 4.2, 4.4 | Social features need consent design first. |
| 5.4, 5.6 | Spatial audio and multi-language after core audio works. |
| 6.2, 6.3 | Fall detection and location sharing need separate safety and privacy review. |
| 7.1, 7.2 | Personalization after onboarding works. |

## Release gates

The MVP is not released to real users until all of these hold:

1. **Latency:** obstacle and crossing alerts meet the 300 ms target on the iPhone, measured on the device.
   - **Local-first check:** the offline core (text reading, object identification) is measured with no network and meets its targets.
2. **Honesty:** every answer path can produce "I'm not sure," and testers confirm the assistant does not guess on text and object tests.
3. **Privacy:** no video or audio is stored by default. A check confirms this on each platform.
4. **Safety review:** a written review of the obstacle and crossing features, done with blind and low-vision co-design participants.
5. **Accessibility:** the full core flow works with VoiceOver on iOS, TalkBack on Android, and no screen on any configuration.
6. **Field test:** co-design participants complete the core tasks on iPhone.

## Open questions

- Which on-device models (vision, OCR, speech) run fast enough on the target iPhones, and what is the minimum supported iOS version?
- Which tasks, if any, should escalate to cloud by default, and which cloud provider and data-handling policy apply to escalations?
- What on-device detection model will meet the 300 ms latency target for obstacles and crossings?
- Which Meta glasses model and SDK version are targeted for the post-MVP milestone, and what are its camera and mic limits?
- Who is in the co-design group, and how are they recruited and compensated?
- What is the legal and liability position for a product that supports mobility decisions?
