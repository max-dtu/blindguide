import {
  Verbosity,
  SpeechCategory,
  SpeechPriority,
  InterruptDecision,
  EscalationDecision,
  isVerbosity,
  decideSpeech,
  renderAnswer,
  decideEscalation,
  CANNOT_SEE_MESSAGE,
} from "./rules.js";

// Placeholder perception: no on-device model is connected yet, so it never
// claims a result. Zero confidence means the answer is spoken as "I'm not sure".
// Local inference in the browser comes later (MVP.md, "Design rules").
async function performTask(task) {
  return { text: `${task} is not available yet`, confidence: 0 };
}

const output = document.getElementById("output");
const alertRegion = document.getElementById("alert-region");
const verbositySelect = document.getElementById("verbosity");
const cloudCheckbox = document.getElementById("cloud-enabled");

let verbosity = Verbosity.NORMAL;
let currentPriority = null;

verbositySelect.addEventListener("change", () => {
  if (isVerbosity(verbositySelect.value)) verbosity = verbositySelect.value;
});

function show(text, { alert = false } = {}) {
  if (alert) {
    alertRegion.textContent = text;
  } else {
    output.textContent = text;
  }
}

// Speak a message through the browser's speech synthesis, applying the shared
// rules: verbosity filters what is said, and safety alerts interrupt other speech.
// The text is always shown on screen too, so deaf-blind users and other
// screen-reader users are not left without it.
function speak(text, priority, category) {
  const request = { text, priority, category };
  const decision = decideSpeech({ request, verbosity, currentPriority });
  if (decision === InterruptDecision.DROP) return;

  if (!("speechSynthesis" in window)) {
    show(text, { alert: category === SpeechCategory.SAFETY_ALERT });
    return;
  }

  if (decision === InterruptDecision.INTERRUPT_AND_SPEAK) {
    window.speechSynthesis.cancel();
  }

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = document.documentElement.lang || "en";
  utterance.onend = () => {
    currentPriority = null;
  };
  currentPriority = priority;
  window.speechSynthesis.speak(utterance);
  show(text, { alert: category === SpeechCategory.SAFETY_ALERT });
}

async function runTask(task) {
  const answer = await performTask(task);
  const escalation = decideEscalation({
    localConfidence: answer.confidence,
    cloudEnabled: cloudCheckbox.checked,
  });

  let text;
  switch (escalation) {
    case EscalationDecision.ANSWER_LOCALLY:
    case EscalationDecision.ANSWER_LOCALLY_WITH_UNCERTAINTY:
      text = renderAnswer(answer);
      break;
    case EscalationDecision.ASK_BEFORE_ESCALATING:
      // Cloud escalation is not implemented yet. Never send anything silently.
      text = "I'm not sure. A cloud check would help, but it is not set up yet.";
      break;
    default:
      text = CANNOT_SEE_MESSAGE;
  }

  speak(text, SpeechPriority.USER_REQUESTED, SpeechCategory.ANSWER);
}

document.getElementById("task-read-text").addEventListener("click", () => runTask("Reading text"));
document.getElementById("task-what-is-this").addEventListener("click", () => runTask("Identifying the object"));
document.getElementById("task-scene").addEventListener("click", () => runTask("Describing the scene"));

document.getElementById("call-human").addEventListener("click", () => {
  speak("Calling a person is not set up yet.", SpeechPriority.USER_REQUESTED, SpeechCategory.ANSWER);
});
