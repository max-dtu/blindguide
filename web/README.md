# BlindGuide web

The web app is the first target (see [MVP.md](../MVP.md)). It runs in a browser on any device, with the camera and microphone later added through the browser.

## What works now

- The main screen: Read text, What is this?, What's around me?, Call a human.
- Settings for verbosity (silent / alerts only / normal / descriptive) and cloud permission.
- Speech output through the browser's speech synthesis, with the shared rules: verbosity filters what is spoken, and safety alerts interrupt other speech.
- Honest answers: low-confidence results are prefixed with "I'm not sure".
- Every spoken response is also shown on screen.

## What is not built yet

- Camera and microphone input. Perception is a placeholder that never claims a result.
- On-device models (local inference in the browser).
- Cloud escalation. The app asks first and does not send anything.
- Call a human (story 6.1).

## Layout

- `index.html`, `styles.css`: the page. Plain HTML with native controls, labels, and a live region for responses.
- `src/rules.js`: the shared MVP rules, ported from `ios/BlindGuideCore`. Keep the two in step.
- `src/app.js`: wires the page to the rules and speech.
- `tests/rules.test.js`: rule tests (Node's built-in test runner).
- `tests/a11y.test.mjs`: loads the page in Chromium, runs the axe audit (WCAG 2.x A/AA), and checks that Read text gives an honest answer.

## Run

```bash
cd web
npm install
npm test                       # rule tests
npx playwright install chromium
node --test tests/             # rule tests and browser tests
```

Serve the folder with any static server to try it by hand, for example `npx http-server .`.
