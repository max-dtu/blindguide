import { test } from "node:test";
import assert from "node:assert/strict";
import {
  Verbosity,
  SpeechCategory,
  SpeechPriority,
  InterruptDecision,
  EscalationDecision,
  allows,
  decideSpeech,
  renderAnswer,
  clampConfidence,
  decideEscalation,
} from "../src/rules.js";

const { SAFETY_ALERT, ANSWER, UNSOLICITED_DETAIL } = SpeechCategory;

test("silent speaks nothing", () => {
  for (const c of [SAFETY_ALERT, ANSWER, UNSOLICITED_DETAIL]) {
    assert.equal(allows(Verbosity.SILENT, c), false);
  }
});

test("alerts only speaks only safety alerts", () => {
  assert.equal(allows(Verbosity.ALERTS_ONLY, SAFETY_ALERT), true);
  assert.equal(allows(Verbosity.ALERTS_ONLY, ANSWER), false);
  assert.equal(allows(Verbosity.ALERTS_ONLY, UNSOLICITED_DETAIL), false);
});

test("normal speaks alerts and answers but not detail", () => {
  assert.equal(allows(Verbosity.NORMAL, SAFETY_ALERT), true);
  assert.equal(allows(Verbosity.NORMAL, ANSWER), true);
  assert.equal(allows(Verbosity.NORMAL, UNSOLICITED_DETAIL), false);
});

test("descriptive speaks everything", () => {
  for (const c of [SAFETY_ALERT, ANSWER, UNSOLICITED_DETAIL]) {
    assert.equal(allows(Verbosity.DESCRIPTIVE, c), true);
  }
});

test("unknown verbosity is rejected", () => {
  assert.throws(() => allows("loud", ANSWER));
});

test("safety alert interrupts user speech", () => {
  const request = { text: "Pole", priority: SpeechPriority.SAFETY, category: SAFETY_ALERT };
  assert.equal(
    decideSpeech({ request, verbosity: Verbosity.NORMAL, currentPriority: SpeechPriority.USER_REQUESTED }),
    InterruptDecision.INTERRUPT_AND_SPEAK,
  );
});

test("safety alert does not interrupt another safety alert", () => {
  const request = { text: "Step down", priority: SpeechPriority.SAFETY, category: SAFETY_ALERT };
  assert.equal(
    decideSpeech({ request, verbosity: Verbosity.NORMAL, currentPriority: SpeechPriority.SAFETY }),
    InterruptDecision.ENQUEUE,
  );
});

test("ordinary answer queues behind current speech", () => {
  const request = { text: "A bakery", priority: SpeechPriority.USER_REQUESTED, category: ANSWER };
  assert.equal(
    decideSpeech({ request, verbosity: Verbosity.NORMAL, currentPriority: SpeechPriority.USER_REQUESTED }),
    InterruptDecision.ENQUEUE,
  );
});

test("verbosity drops detail before priority is considered", () => {
  const request = { text: "Sky", priority: SpeechPriority.AMBIENT, category: UNSOLICITED_DETAIL };
  assert.equal(
    decideSpeech({ request, verbosity: Verbosity.NORMAL, currentPriority: null }),
    InterruptDecision.DROP,
  );
});

test("silent mode drops even safety alerts", () => {
  const request = { text: "Pole", priority: SpeechPriority.SAFETY, category: SAFETY_ALERT };
  assert.equal(
    decideSpeech({ request, verbosity: Verbosity.SILENT, currentPriority: null }),
    InterruptDecision.DROP,
  );
});

test("confident answer is stated plainly", () => {
  assert.equal(renderAnswer({ text: "Walk signal on", confidence: 0.95 }), "Walk signal on");
});

test("low-confidence answer is prefixed with uncertainty", () => {
  assert.equal(
    renderAnswer({ text: "Ibuprofen 200 mg", confidence: 0.4 }),
    "I'm not sure. It might be: Ibuprofen 200 mg",
  );
});

test("answer at the threshold is stated plainly", () => {
  assert.equal(renderAnswer({ text: "Door", confidence: 0.7 }), "Door");
});

test("confidence is clamped to 0..1", () => {
  assert.equal(clampConfidence(1.7), 1);
  assert.equal(clampConfidence(-0.3), 0);
});

test("confident local answer never escalates", () => {
  assert.equal(decideEscalation({ localConfidence: 0.9 }), EscalationDecision.ANSWER_LOCALLY);
});

test("low confidence asks before escalating", () => {
  assert.equal(
    decideEscalation({ localConfidence: 0.3, cloudEnabled: true }),
    EscalationDecision.ASK_BEFORE_ESCALATING,
  );
});

test("outside knowledge asks before escalating", () => {
  assert.equal(
    decideEscalation({ localConfidence: 0.9, needsOutsideKnowledge: true, cloudEnabled: true }),
    EscalationDecision.ASK_BEFORE_ESCALATING,
  );
});

test("user second opinion asks before escalating", () => {
  assert.equal(
    decideEscalation({ localConfidence: 0.9, userRequestedSecondOpinion: true, cloudEnabled: true }),
    EscalationDecision.ASK_BEFORE_ESCALATING,
  );
});

test("cloud disabled never escalates and admits uncertainty", () => {
  assert.equal(
    decideEscalation({ localConfidence: 0.2, cloudEnabled: false }),
    EscalationDecision.ANSWER_LOCALLY_WITH_UNCERTAINTY,
  );
});
