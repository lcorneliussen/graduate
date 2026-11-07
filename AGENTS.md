# Working on graduate

Read [docs/plan.md](docs/plan.md) first. If `HANDOVER.local.md` exists, read it
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

## Stack

The CLI is Rust, with ratatui for anything interactive. Go only for a reason
you state. Quick probes and spikes may be anything; they do not ship. Skills
are Markdown (`SKILL.md`), linked into each agent's skills folder the way
Omarchy links its own (`~/.agents/skills`, `~/.claude/skills`,
`~/.codex/skills`, `~/.pi/agent/skills`).

## Verifying

- Anything that opens a window, the bar, a menu or a notification is driven in
  an **omabox** box, never on the real desktop.
- Moving work between machines touches real data. Rehearse with throwaway
  folders and say which steps were actually run. A move must fail closed:
  unpushed branches, stashes or untracked files stop it.
- Never move or delete an agent session file without a backup next to it.

## Talking to other agents

graduate is allowed to call agent CLIs (`claude -p`, `codex exec`, ...) for
judgement. Keep each call's prompt and answer in the log of what it decided, so
a choice can be checked later.
