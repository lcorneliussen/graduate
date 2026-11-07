# Working on graduate

The plan lives in the GitHub issues of `lcorneliussen/graduate`: read the pinned
**Design decisions** issue (#1) first, then the open milestone's issues
(`gh issue list`). Issues labelled `decision` wait for the user.
Record new decisions there, not in the source. If `HANDOVER.local.md` exists, read it
next: it is the untracked, machine-specific part of how this project started.

## This repo is meant to be public

No real machine, ego, customer, tenant or host names in code, docs, tests,
commit messages or screenshots. Use the invented set: egos **Acme / Personal /
Work**, machines **box / laptop / desk**, hosts under `example.com`. Anything
machine-specific goes in `*.local.md` files, which are gitignored. Ask before
the first push, and before making the GitHub repo public.

## Say which machine

Agents here are often driven remotely (a herdr remote over Tailscale SSH), so
"here" means different machines to the user and to you. Whenever installing,
running or "is it there" comes up, say "on <hostname>, driven from <peer>":
`hostname`, and the `SSH_CONNECTION` peer resolved with `tailscale status`.
`skill/scripts/where` prints exactly that.

## Stack

The CLI is Rust, with ratatui for anything interactive. Go only for a reason
you state. Quick probes and spikes may be anything; they do not ship. Skills
are Markdown (`SKILL.md`), linked into each agent's skills folder the way
Omarchy links its own (`~/.agents/skills`, `~/.claude/skills`,
`~/.codex/skills`, `~/.pi/agent/skills`, `~/.hermes/skills`): `install.sh`.
The skill's helpers in `skill/scripts/` are bash, as thin glue around `jq`,
`git` and `herdr`; the Rust CLI (#13) takes their place.

## Verifying

- `test/run.sh` after every change to `skill/scripts/`; `test/run.sh --live`
  and `test/e2e.sh` before a release (they start real agents in throwaway
  herdr spaces and clean up after themselves).
- Anything that opens a window, the bar, a menu or a notification is driven in
  an **omabox** box, never on the real desktop.
- Moving work between machines touches real data. Rehearse with throwaway
  folders and say which steps were actually run. A move must fail closed:
  unpushed branches, stashes or untracked files stop it.
- Never move or delete an agent session file without a backup next to it.

## Commits, PRs, releases

No model attribution: no `Co-Authored-By` trailer, no "Generated with" line.
A release bumps `VERSION`, adds a `CHANGELOG.md` entry, and gets an annotated
tag `vX.Y.Z` and a GitHub release.

## Talking to other agents

graduate is allowed to call agent CLIs (`claude -p`, `codex exec`, ...) for
judgement. Keep each call's prompt and answer in the log of what it decided, so
a choice can be checked later.
