// Shared MVP rules for the web app. Port of ios/BlindGuideCore (Swift).
// Keep the two in step: see MVP.md, "Design rules".

// Verbosity levels, quietest to chattiest (story 5.2).
export const Verbosity = Object.freeze({
  SILENT: "silent",
  ALERTS_ONLY: "alertsOnly",
  NORMAL: "normal",
  DESCRIPTIVE: "descriptive",
});

const VERBOSITY_RANK = {
  [Verbosity.SILENT]: 0,
  [Verbosity.ALERTS_ONLY]: 1,
  [Verbosity.NORMAL]: 2,
  [Verbosity.DESCRIPTIVE]: 3,
};

export const SpeechCategory = Object.freeze({
  SAFETY_ALERT: "safetyAlert",
  ANSWER: "answer",
  UNSOLICITED_DETAIL: "unsolicitedDetail",
});

export const SpeechPriority = Object.freeze({
  AMBIENT: 0,
  USER_REQUESTED: 1,
  SAFETY: 2,
});

export function isVerbosity(value) {
  return Object.prototype.hasOwnProperty.call(VERBOSITY_RANK, value);
}

// Whether the given verbosity level allows speech of the given category.
// In silent mode nothing is spoken; safety alerts still reach the user as
// haptic or tone cues, which the UI layer handles.
export function allows(verbosity, category) {
  if (!isVerbosity(verbosity)) throw new Error(`unknown verbosity: ${verbosity}`);
  switch (verbosity) {
    case Verbosity.SILENT:
      return false;
    case Verbosity.ALERTS_ONLY:
      return category === SpeechCategory.SAFETY_ALERT;
    case Verbosity.NORMAL:
      return category !== SpeechCategory.UNSOLICITED_DETAIL;
    case Verbosity.DESCRIPTIVE:
      return true;
    default:
      return false;
  }
}

export const InterruptDecision = Object.freeze({
  INTERRUPT_AND_SPEAK: "interruptAndSpeak",
  ENQUEUE: "enqueue",
  DROP: "drop",
});

// Decide what happens to a new message given what is currently spoken.
// Verbosity is checked first, then priority (story 5.3: safety interrupts).
export function decideSpeech({ request, verbosity, currentPriority }) {
  if (!allows(verbosity, request.category)) return InterruptDecision.DROP;
  if (currentPriority === null || currentPriority === undefined) return InterruptDecision.ENQUEUE;
  if (request.priority === SpeechPriority.SAFETY && currentPriority !== SpeechPriority.SAFETY) {
    return InterruptDecision.INTERRUPT_AND_SPEAK;
  }
  return InterruptDecision.ENQUEUE;
}

// Confidence in 0..1, clamped (story 5.5).
export function clampConfidence(value) {
  return Math.min(Math.max(value, 0), 1);
}

export const MINIMUM_CONFIDENCE = 0.7;

// Speak an answer honestly. Low-confidence answers are never stated as fact.
export function renderAnswer(answer, threshold = MINIMUM_CONFIDENCE) {
  if (clampConfidence(answer.confidence) < threshold) {
    return `I'm not sure. It might be: ${answer.text}`;
  }
  return answer.text;
}

export const CANNOT_SEE_MESSAGE =
  "I can't tell from here. Try moving closer, or check the light.";

export const EscalationDecision = Object.freeze({
  ANSWER_LOCALLY: "answerLocally",
  ANSWER_LOCALLY_WITH_UNCERTAINTY: "answerLocallyWithUncertainty",
  ASK_BEFORE_ESCALATING: "askBeforeEscalating",
});

// Local-first: answer on the device by default. Cloud only when needed, and
// always announced and declinable (MVP.md, "Design rules").
export function decideEscalation({
  localConfidence,
  needsOutsideKnowledge = false,
  userRequestedSecondOpinion = false,
  cloudEnabled = false,
}) {
  const needsCloud =
    userRequestedSecondOpinion ||
    needsOutsideKnowledge ||
    clampConfidence(localConfidence) < MINIMUM_CONFIDENCE;

  if (!needsCloud) return EscalationDecision.ANSWER_LOCALLY;
  if (!cloudEnabled) return EscalationDecision.ANSWER_LOCALLY_WITH_UNCERTAINTY;
  return EscalationDecision.ASK_BEFORE_ESCALATING;
}
