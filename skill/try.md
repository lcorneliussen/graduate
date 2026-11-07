# Conversation → try

A *try* is one dated folder holding everything worth keeping from a piece of
work: a writeup, links to whatever live files it changed, and the artifacts it
produced. A herdr space points at it, so it can be reached from the terminal.

The value is the README, not the folder. Write it for someone, likely the user
months later, who arrives with no memory of the conversation.

## 1. Find the tries root

```bash
"$SKILL_DIR"/scripts/tries-root
```

It checks, first hit wins: `$GRADUATE_TRIES_ROOT`; the cwd of existing herdr
spaces that are tries; `$TRY_PATH` or `try init` in a shell rc; then
`~/Work/tries` and `~/src/tries`. It fails when none of those has a
`YYYY-MM-DD-*` folder in it. Then say which root you picked and why, and ask
before creating one.

**Never run `try`, `try exec` or `try clone`.** They need an interactive
terminal and abort under an agent. Make the folder yourself; `try` only needs
the naming convention to find it.

## 2. Name it, lightly

`YYYY-MM-DD-<subject>` in kebab case, today's date. Name it for the subject,
not the activity: `2026-09-14-hyprland-window-titlebars`, not
`2026-09-14-config-changes`. No naming round with the user; that is for
projects.

If the folder exists already, add to it rather than making a second one.

## 3. Fill it

```
README.md              the writeup (below)
<brief>.md             a paste-ready prompt or issue draft, kept separate
<live-file> -> …       a symlink, never a copy
screenshots/           numbered, before/after in the name
```

- **Link live config, never copy it.** A copy drifts the moment the real file
  is edited: `ln -sfn ~/.config/hypr/titlebars.lua "$T/titlebars.lua"`, then
  check with `readlink -f`.
- **Rescue session artifacts.** Screenshots and scratch files in the session's
  scratchpad vanish with it. Copy them in, renamed to say what they show
  (`01-before-washed-out.png`).
- **Link the conversation.** Note the agent and the session file it came from
  (for Claude, `~/.claude/projects/<cwd-slug>/<session-id>.jsonl`), so the
  try can be traced back. Link it; never move it.

### The README

Only what applies, roughly in this order:

- **What this is.** One or two sentences, plus the versions it was built
  against. Version drift is the main reason a writeup goes stale.
- **The mechanism.** The load-bearing idea, with the actual snippet. Why it
  works, not only what to paste.
- **Gotchas.** Anything that silently did the wrong thing, cost real debugging
  time, or destroyed something. The most valuable section. A table works when
  there are several.
- **Reproduce.** Commands verified in the session. Mark anything not run.
- **Rejected approaches.** What lost, and why, so it is not reopened.
- **Open threads.** What is unfinished, with enough context to resume.
- **Where it came from.** Machine, agent, session id, date.

Be honest about what was verified and what was assumed, and record the
versions behind any line numbers or paths quoted from someone else's repo.

## 4. Hand over

[handover.md](handover.md), without starting an agent: trust the folder and
attach it as a space. A try needs nobody working in it yet.

If the try holds code that already runs on the machine (something in
`~/.local/bin`, a systemd unit, a Hyprland snippet, a shell plugin), say so at
the end: it is a candidate for [project.md](project.md).
