# BlindGuide – MVP

This document defines the first release of BlindGuide. It is scoped from [USER_STORIES.md](USER_STORIES.md). Story IDs refer to that file.

## Goal
Prove that an audio-first assistant can help a blind or low-vision person with everyday tasks, safely and honestly, on the devices people already own. The MVP succeeds if real users in co-design and field tests can complete the core tasks and say they trust the assistant more than they distrust it.

## Supported devices

The MVP supports three input and output configurations. The phone is always the compute hub. Glasses are a peripheral that provides camera, microphone and audio.

| Configuration | Camera | Microphone | Audio out | Status |
|---|---|---|---|---|
| **iPhone** (primary) | Phone camera | Phone mic | Phone speaker, headphones, or bone conduction / open-ear | MVP |
| **Android phone** | Phone camera | Phone mic | Phone speaker, headphones, or bone conduction / open-ear | MVP |
| **Meta smart glasses** | Glasses camera (via phone companion link) | Glasses mic | Glasses open-ear speakers | MVP, after the phone configurations work |

Notes:
- **iPhone first:** the primary user (Maya) uses VoiceOver on an iPhone, so the iOS experience is the reference implementation.
- **Android** must support TalkBack from the start.
- **Meta glasses:** the phone runs the app and connects to the glasses through the vendor's device SDK. Glasses-specific input (tap, voice) maps to the same commands as the phone. The glasses SDK's exact capabilities (camera frame rate, streaming latency, mic access) must be verified before committing to the glasses milestone.
- **Other devices** (other smart glasses, watches, dedicated hardware) are out of scope for the MVP.

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
   │  - Cloud reasoning (scene, text, object)  │  with "not sure" fallback
   │  - Privacy controls (no storage by default)
   └────────────┬─────────────┘
                │
        Accessibility layer: VoiceOver (iOS), TalkBack (Android)
```

Design rules:
1. **Safety alerts never depend on the network.** They run on the phone, under the latency target (300 ms).
2. **Cloud is for reasoning, not for hazards.** Descriptions can take up to 1.5 s and can use the network.
3. **Device differences stay in the adapter.** The core logic, prompts, verbosity rules and privacy rules are the same on every platform.
4. **Everything works without the screen.** No feature may require visual UI as its only path.

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

1. **Latency:** obstacle and crossing alerts meet the 300 ms target on each device configuration, measured on the device.
2. **Honesty:** every answer path can produce "I'm not sure," and testers confirm the assistant does not guess on text and object tests.
3. **Privacy:** no video or audio is stored by default. A check confirms this on each platform.
4. **Safety review:** a written review of the obstacle and crossing features, done with blind and low-vision co-design participants.
5. **Accessibility:** the full core flow works with VoiceOver on iOS, TalkBack on Android, and no screen on any configuration.
6. **Field test:** co-design participants complete the core tasks on at least one device of each configuration.

## Open questions

- Which cloud model and provider will handle scene, text and object reasoning, and what is the data-handling policy?
- Which Meta glasses model and SDK version are targeted, and what are its camera and mic limits?
- What on-device detection model will meet the latency target for obstacles and crossings?
- Who is in the co-design group, and how are they recruited and compensated?
- What is the legal and liability position for a product that supports mobility decisions?
