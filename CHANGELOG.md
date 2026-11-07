# Changelog

## graduate 0.1.0 — 2026-11-07

First release: the `graduate` agent skill.

- One skill for every stage. It says which machine it is on and which one
  drives it, works out whether it was called from a conversation, a try or a
  project, and takes the work one stage up. What the user says wins over that
  default.
- **Conversation → try.** A dated folder in the tries root, with a README
  written for a reader months later, links to the live files the work touched,
  and the session's artifacts rescued. It replaces the older `as-try` skill.
- **Try → project.** A name picked by the user from candidates checked against
  `~/Work`, `PATH`, pacman, the AUR and GitHub; then `git init`, a README that
  links back, `AGENTS.md` and `.gitignore`. Private on GitHub, and only when
  asked.
- **Shapes and faces.** A plugin, or a binary whose CLI always comes first,
  with an optional TUI, GUI and bundled plugin. Rust by default.
- **Handover.** The new folder is marked trusted for Claude Code and Codex
  (atomic, one key, safe to repeat). It opens as a herdr space without taking
  focus. For a project, an agent starts there and is briefed; it skips Codex's
  update prompt so the brief is not lost.
- Folders listed in `~/Work/emigrated.jsonl` are reported as moved, with where
  to.
- `install.sh` links the skill into `~/.agents`, `~/.claude`, `~/.codex`,
  `~/.pi/agent` and `~/.hermes`.
- Tests: `test/run.sh` (offline, `--live` with real agents) and `test/e2e.sh`
  (fresh agents follow the skill in throwaway folders).
