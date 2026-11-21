# BlindGuide – User Stories

**Product:** An AI assistant on a phone or smart glasses that sees through the camera, listens through the mic and talks back through audio (ideally bone-conduction or open-ear, so the user can still hear traffic).

**Personas**
- **Maya (34):** fully blind since birth. Uses a white cane and an iPhone with VoiceOver. Commutes to an office job.
- **Ahmed (67):** lost most of his sight to macular degeneration. Not very technical, lives alone.
- **Lena (22):** student with low vision. Has a guide dog and wears smart glasses.
- **Sam:** Maya's sighted friend or family member (a secondary user).

Format: *As a [persona], I want [goal], so that [benefit].* Each story has acceptance criteria (AC) and a priority (P0 = MVP, P1 = next, P2 = later).

---

## Epic 1 – Safe mobility and navigation

**1.1 Obstacle warnings (P0)**
As Maya, I want to hear a short warning when something is in my path at head or chest height (branches, open truck doors, signposts), so that I can avoid things my cane can't detect.
- AC: Warns within 300 ms. Gives direction and rough distance ("Pole, slightly left, two steps"). Stays silent when the path is clear.
- AC: Has a "quiet mode" that gives haptic or tone cues only.

**1.2 Crossing the street (P0)**
As Maya, I want to be told the pedestrian signal state and whether cars are moving, so that I can decide when to cross.
- AC: Reports "Walk signal on", "Don't walk" or "I can't see a signal". It never says "safe to cross". The decision stays with the user.
- AC: Warns if the user drifts outside the crosswalk.

**1.3 Turn-by-turn walking directions (P0)**
As Ahmed, I want spoken walking directions that use landmarks ("past the bakery, turn right"), so that I can reach places without counting blocks.
- AC: Combines GPS with camera-recognized landmarks. Repeats an instruction when asked "Where now?"

**1.4 Finding the exact door (P1)**
As Maya, I want guidance for the last 10 meters to the actual entrance, so that I don't end up at the wrong door when GPS says "You have arrived".
- AC: Reads signs and house numbers and recognizes door shapes. Guides with clock-face directions ("door at 2 o'clock, 5 meters").

**1.5 Indoor navigation (P1)**
As Lena, I want help finding the elevator, stairs, restrooms or a specific room in an unfamiliar building, so that I don't have to ask strangers.
- AC: Reads room-number signs and directories. Warns about stairs going down.

**1.6 Public transport (P1)**
As Maya, I want to know which bus is arriving and when my stop is next, so that I board the right one and get off on time.
- AC: Reads the bus number and destination from its display. Combines GPS with live transit data. Alerts one stop ahead.

**1.7 Free seat and queue finding (P2)**
As Ahmed, I want to know where a free seat is on the train or in a waiting room, so that I can sit without groping around.

---

## Epic 2 – Reading and understanding text

**2.1 Instant text reading (P0)**
As Ahmed, I want to point at a letter, menu or label and have it read aloud, so that I can handle my own mail.
- AC: Gives guidance until the text is in frame ("Move up a little"). Summarizes first, then reads in full if asked.

**2.2 Documents and bills (P0)**
As Ahmed, I want a bill summarized ("Electricity, 84 euros, due 3 December"), so that I know what matters without hearing every line.
- AC: Picks out the amount, due date and sender. Never pays or fills in payment details on its own.

**2.3 Restaurant menus (P1)**
As Maya, I want to ask "What vegetarian dishes are under 15 euros?", so that I can order on my own.

**2.4 Screens and displays (P1)**
As Lena, I want the app to read ATMs, ticket machines, microwaves and thermostats that have no audio, so that I can use them myself.
- AC: Tracks the finger position: "Your finger is on 'Withdraw'."

**2.5 Handwriting and notes (P2)**
As Ahmed, I want handwritten cards from my grandchildren read to me.

---

## Epic 3 – Identifying objects and everyday tasks

**3.1 What is this? (P0)**
As Ahmed, I want to hold up an item and ask "What is this?", so that I can tell a can of soup from a can of beans.

**3.2 Medication check (P0)**
As Ahmed, I want my pill bottles identified and the dose read from the label, so that I take the right medicine.
- AC: Reads the name, strength and instructions exactly as printed. If unsure, says so and suggests calling the pharmacist. Never guesses.

**3.3 Expiry dates and food safety (P1)**
As Ahmed, I want expiry dates read and to be told if food looks spoiled or moldy.

**3.4 Money (P0)**
As Maya, I want banknotes and coins identified and my change counted, so that I can't be short-changed.

**3.5 Clothing and colors (P1)**
As Lena, I want to know clothing colors and patterns and whether an outfit matches, and to hear about stains.

**3.6 Finding a dropped item (P1)**
As Maya, I want to say "Find my keys" and be guided by voice or tones to where they fell, so that I don't have to sweep the floor with my hands.

**3.7 Cooking help (P2)**
As Ahmed, I want to hear the stove dial settings, whether a pan is boiling, and recipe steps hands-free.

**3.8 Shopping (P1)**
As Maya, I want help finding a product on a shelf ("Oat milk, the second shelf, to your right"), and to have prices and offers read.

---

## Epic 4 – People and social awareness

**4.1 Who is here? (P1)**
As Maya, I want to be told when a person I have saved (who agreed to be saved) approaches, so that I can greet colleagues by name.
- AC: Recognizes only people the user enrolled with their consent. Strangers are described only in general terms ("A person is walking toward you").

**4.2 Social cues (P2)**
As Lena, I want to quietly ask "Is the person talking to me?" or "Did they hold out a hand?", so that I can respond naturally.

**4.3 Describing a scene (P0)**
As Maya, I want to ask "What's around me?" and get a short description, so that I understand a new place (a café, a park or a meeting room).
- AC: Gives the short version first, with more detail on request ("Tell me more").

**4.4 Photos and media (P2)**
As Lena, I want photos in my messages and social feeds described, so that I'm included in group chats.

---

## Epic 5 – Interaction design (audio-first)

**5.1 Hands-free wake and voice (P0)**
As Lena, holding a guide-dog harness, I want to control everything by voice or a single tap on my glasses, so that both my hands stay free.

**5.2 Verbosity control (P0)**
As Maya, I want to set how chatty the assistant is (silent / alerts only / normal / descriptive), so that it doesn't overload me in busy places.

**5.3 Priority interruption (P0)**
As Maya, I want safety alerts to interrupt any ongoing speech, so that a warning is never queued behind a menu reading.

**5.4 Spatial audio (P1)**
As Lena, I want warnings to come from the direction of the hazard (left ear or right ear), so that I can react without having to work out the words.

**5.5 Honest uncertainty (P0)**
As every user, I want the assistant to say "I'm not sure" or "Too dark to see" instead of guessing, so that I can trust what it tells me.

**5.6 Language and voice (P1)**
As Ahmed, I want the app to speak my language at an adjustable speed, so that I can follow comfortably.

---

## Epic 6 – Help, safety and trust

**6.1 Call a human (P0)**
As Ahmed, I want to say "Call my daughter" or "Get a volunteer" and share my live camera view, so that a person can help when the AI can't.

**6.2 Fall or emergency detection (P1)**
As Ahmed, I want the app to notice a fall or a cry for help and offer to call emergency services or my contact.
- AC: Asks first ("Are you okay? Calling Sara in 10 seconds unless you say stop").

**6.3 Share my location (P1)**
As Sam, I want to see where Maya is when she shares her journey, so that I can help her remotely if she gets lost.

**6.4 Battery and connection awareness (P0)**
As Maya, I want warnings about low battery or a lost connection, and a degraded offline mode (obstacle warnings and basic text reading keep working), so that I am never left without help in the middle of a street.

**6.5 Privacy (P0)**
As every user, I want video processed only when I'm using the app, with no recordings stored unless I choose, and bystanders' faces not saved, so that I and the people around me keep our privacy.

---

## Epic 7 – Learning and personalization

**7.1 Remember my places (P1)**
As Maya, I want to save places ("my desk", "front door", "pharmacy") and routes, so that guidance gets faster over time.

**7.2 Remember my things (P2)**
As Ahmed, I want to teach it my own items ("this is my blue mug", "my house key"), so that it can find them later.

**7.3 Onboarding by voice (P0)**
As Ahmed, I want a fully voice-guided setup with no visual steps, so that I can install it without sighted help.

---

## Suggested MVP slice
1.1 Obstacles · 1.2 Crossing · 1.3 Directions · 2.1 Read text · 2.2 Bills · 3.1 What is this? · 3.2 Medication · 3.4 Money · 4.3 Scene description · 5.1–5.3, 5.5 Interaction · 6.1 Call a human · 6.4 Battery/offline · 6.5 Privacy · 7.3 Voice onboarding

## Key non-functional requirements
- **Latency:** under 300 ms for safety alerts and under 1.5 s for descriptions. This probably requires on-device detection for hazards, with the cloud LLM used for rich reasoning.
- **Safety:** the assistant supplements the cane or guide dog and never replaces them. Its wording avoids false assurance.
- **Battery:** at least 4 hours of active guidance on glasses with a phone tethered.
- **Accessibility:** everything works with VoiceOver and TalkBack and without the screen.
- **Testing:** co-design and field tests with blind and low-vision users from the start.
