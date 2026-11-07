---
name: graduate
description: >
  Take work one stage up and give it a permanent home: a loose agent
  conversation becomes a dated try folder, a try becomes a named git project in
  ~/Work, and a project gets its shape (a plugin, or a binary with a CLI and an
  optional TUI or GUI). Use when asked to save, park, keep, archive or write up
  what this conversation produced ("make this a try", "save this as a try",
  "park this somewhere I can find it", "attach this to herdr as a space",
  "/as-try"), to graduate or promote something ("graduate this", "make this a
  real project", "turn this try into a project", "this script became load
  bearing", "make it a proper CLI / plugin / app"), or to hand the work over to
  a fresh agent in its new home.
---

# graduate

Work moves through three stages. graduate takes it **one stage up** from
wherever it is called, and gives it a home that can be found again.

| Stage | Lives in | graduate takes it to |
|---|---|---|
| Conversation | the agent's session store | **a try**: a permanent dated folder ([try.md](try.md)) |
| Try | `<tries root>/YYYY-MM-DD-<subject>/`, no git | **a project**: `~/Work/<name>/`, git, a real name ([project.md](project.md)) |
| Project | `~/Work/<name>/`, git | **its shape**: a plugin, or a binary with faces ([shapes.md](shapes.md)) |

Read only the file for the flow you take.

## 1. Say where you are

Agents here are often driven from another machine, so "here" means different
things to the user and to you. Start every run with:

```bash
"$SKILL_DIR"/scripts/where
```

(`$SKILL_DIR` is the folder this file is in.) It prints the host, the machine
driving the session, the folder, and which stage that folder is. Say it in your
first line: "on <host>, driven from <peer>". If it reports the folder as
**emigrated**, stop: the work lives elsewhere now, and it tells you where.

## 2. Pick the flow

Use what `where` reports, then your judgement:

- **In a try folder** → the user wants an actual project: [project.md](project.md).
- **In a project** → its shape: [shapes.md](shapes.md). A shape change is
  usually a branch, not a new folder.
- **Anywhere else, or in a folder the conversation has nothing to do with** →
  the conversation flow: [try.md](try.md). This is the default. A try needs no
  proper name and no git; it only makes the work permanent.

The user's words win over the default. "Make this a project" from a
conversation goes straight to [project.md](project.md) when the work is
clearly one thing and started as code; skip the try then.

## 3. Check the scope

If the conversation covered more than one subject, say so and list them. Each
subject gets its own home, and a home may be a branch of an existing project
rather than a new folder. Ask which ones to take before making anything.

## 4. Run the flow, then hand over

Each flow ends at [handover.md](handover.md): trust the new folder for the
agents, open it as a herdr space, and, for a project, start an agent there and
hand the work over.

## Rules for every flow

- **Never write into an agent's session store** (`~/.claude/projects/…`,
  `~/.codex/sessions/…`). Link to session files, never move or edit them.
- **Private by default.** Nothing goes to GitHub without the user saying so,
  and nothing goes public without a check for private names (see
  [project.md](project.md)).
- **Anything with a window, the bar, a menu or a notification** is tried in an
  omabox box, never on the user's desktop.
- **Say what you ran.** Mark every step you did not actually run.
- **Moving work to another machine** is not in this skill yet. Say so if asked,
  and leave the work where it is.
