# Plan

Decisions taken so far, and what is still open. Each decision says why, so it
is not reopened from scratch.

## Stages

| Stage | Where | Moving it to another machine (emigrating) |
|---|---|---|
| **Conversation** | The agent's session store, e.g. Claude's `~/.claude/projects/<cwd-slug>/<id>.jsonl` (`cass` indexes the stores of most agents) | Copy the session file. The slug is derived from the path, so a Mac's `/Users/<you>` gives a different one. Session formats are internal: best effort |
| **Try** | `~/Work/tries/YYYY-MM-DD-<subject>/`, no git | Zip, copy, unpack on the target; leave a tombstone |
| **Project** | `~/Work/<name>/`, git | Set up the main dev home on the target. Fail closed when anything is not on the remote: unpushed branches, stashes, untracked files |

**Tombstone.** Emigrating a try or conversation leaves in the old folder:
`backup-YYYY-MM-DD.zip` and an `AGENTS.md` saying "emigrated to
`<machine>:<path>` on `<date>`; do not work here". It also appends a line to
`~/Work/emigrated.jsonl`, which `~/Work/AGENTS.md` points at, so an agent that
lands in a dead folder is told where the work went.

"Emigrate" is the word from the side being left (the arriving side
immigrates). The CLI verb is the neutral `move`.

## Homes

- **Homed**: the project lives on one machine; the others reach it remotely
  (a herdr session, later a herdr-app space). The registry records the machine
  and session.
- **Synced**: a checkout on every machine, kept in step through GitHub. Nothing
  to emigrate: `move` only changes which machine is the main dev home.

## Graduating

When a try holds code that runs on the machine (something in `~/.local/bin`, a
systemd unit, a Hyprland snippet, a shell plugin), graduate pushes to make it a
proper project:

1. Find a name, on the spot (an agent CLI proposes, the user picks).
2. `~/Work/<name>/`, git. Skip the try when the work started as code.
3. The README links back to the tries or conversation it grew from.
4. Give it the right shape: a CLI, an Omarchy plugin, an app (Omarchy's
   `omarchy-app` skill). Omarchy work is always tested in omabox.
5. Move the stack: quick-check languages give way to Rust (ratatui for TUIs),
   or Go with a stated reason. Existing projects keep theirs unless asked.
6. Push to GitHub only through the privacy gate. Private by default; public
   only when the user says so.

## The skills

One skill per destination, all sharing the same first steps:

| Skill | Takes it to |
|---|---|
| `graduate-try` | a dated try folder (replaces today's `as-try` skill) |
| `graduate-project` | a top-level `~/Work/<name>/` folder with git |
| `graduate-cli` | a Rust CLI with its packaging |
| `graduate-plugin` | an Omarchy shell plugin (or another host's plugin) |
| `graduate-app` | a desktop app (`omarchy-app` on Omarchy) |

Shared first steps:

1. **Where am I?** In a try folder: the try flow. In a project: the project
   flow. In a conversation unrelated to the current folder: the conversation
   flow. Also say which machine, and which machine it is driven from.
2. **What is the scope?** If the conversation covered more than one subject,
   say so and split it: each subject goes to its own home, which may be an
   existing project's branch rather than a new project.
3. **Name it** right there, when a new folder is needed.
4. **Hand over.** Create a herdr space at the new home, start an agent in it,
   and hand over through the herdr CLI (`herdr agent prompt … --wait`), then
   check its summary against what was meant. The first handover, of this very
   project, is described in its own `HANDOVER.local.md`.

   **Auto-trust the new home.** A fresh agent stops at its folder-trust prompt
   before it takes a prompt. graduate created the folder and knows what is in
   it, so it marks it trusted before starting the agent: Claude keeps
   `projects["<path>"].hasTrustDialogAccepted = true` in `~/.claude.json`;
   Codex keeps a per-project `trust_level` in `~/.codex/config.toml`. Both
   files are rewritten by running agents: write them atomically (read, change
   one key, rename into place), and only for folders graduate itself created.

Open: whether the shared steps live in one `graduate` skill the others call,
or are repeated in each. One shared skill is less drift; five standalone ones
trigger more reliably.

## The CLI

`graduate status | move <machine> | graduate | open`, plus a registry of
projects: name, stage, home kind, home machine and path, repo, visibility,
ego. The registry is its own private synced git repo, not omaego's config
repo, so graduate never depends on omaego.

It calls agent CLIs (`claude -p`, `codex exec`, ...) for judgement: naming,
privacy review, readiness, porting a stack.

## Privacy gate

A pre-push hook that refuses a push to a public remote when the diff or the
history contains a name that must stay private. Names come from:

- omaego, when installed: the real ego names and the tenant hosts in its app
  URLs (`egos.toml`);
- otherwise a deny-list the user keeps;
- always gitleaks, for secrets.

## omaego, optional

graduate stands alone. With omaego installed it also uses: omaego's view of
the tailnet for machine names, the ego a project belongs to (a project under
Personal may go public; one under Work or a customer ego stays private), the
names above for the gate, and `omaego remote open` to open a homed project.

Rejected: building this into omaego. omaego is public and meant for the
Omarchy plugin marketplace; a project-lifecycle tool would widen it too much.

## Machine-wide agent instructions

Omarchy primes agents with **skills only**: it links each one into every
agent's skills folder. There is no shared instructions file. graduate uses the
same pattern for instructions: one source, `~/.agents/AGENTS.md`, imported by
`~/.claude/CLAUDE.md` (`@~/.agents/AGENTS.md`) and linked as
`~/.codex/AGENTS.md` and `~/.pi/agent/AGENTS.md`. Gemini reads `GEMINI.md`
and needs its own link. Rules that belong there: say which machine; Omarchy
work always in omabox; check before pushing anything public; the stack
preference.

## Phases

1. **Writing only.** `~/Work/AGENTS.md` (stages, homes, rules, pointer to
   `emigrated.jsonl`). The skills, starting with `graduate-try` replacing
   `as-try`, kept in this repo and linked out.
2. **The machine check** as a session-start hook: "on X, driven from Y".
3. **The privacy gate**, installed by `graduate-project`.
4. **The CLI and registry.** `open` delegates to omaego remotes when present.
5. **herdr-app**: homes become spaces in each ego's window, once omaego
   supports herdr-app.

Phases 1 and 2 already prevent the mix-up this project started from.
