# graduate

Take work from wherever it is (a loose agent conversation, a dated try folder,
a script that quietly became load bearing) to a proper project: named, in its
own folder, git managed, on GitHub when it may be, and on a stack meant to
last. Every step leaves a home that can be found again, and says which machine
it is on.

graduate is an agent skill. It works with Claude Code, Codex, pi, Hermes and
any agent that reads `~/.agents/skills`.

## Stages

| Stage | Lives in | `graduate` takes it to |
|---|---|---|
| **Conversation** | the agent's session store | **a try**: a permanent dated folder with a writeup, links to the live files it touched, and a herdr space |
| **Try** | `~/Work/tries/YYYY-MM-DD-<subject>/`, no git | **a project**: `~/Work/<name>/`, git, a name found with you, a README that links back |
| **Project** | `~/Work/<name>/`, git | **its shape**: a plugin, or a binary with a CLI and optional faces |

One step at a time, from wherever it is called. A try needs no naming round: a
date and a subject make it permanent. Once you graduate a try, it is clear you
want an actual project.

## Install

```bash
git clone https://github.com/lcorneliussen/graduate ~/Work/graduate
~/Work/graduate/install.sh
```

`install.sh` links `skill/` into `~/.agents/skills` and `~/.claude/skills`,
and into `~/.codex/skills`, `~/.pi/agent/skills` and `~/.hermes/skills` when
those agents are set up. It changes nothing else, and running it again is
safe. The links point at the checkout, so `git pull` updates the skill.
`./install.sh --uninstall` removes them.

It needs `bash`, `jq` and `git`. Optional extras: [herdr](https://herdr.dev)
for spaces and handovers, `tailscale` to name the machine driving the session,
`gh` for GitHub, and `gitleaks` for the check before anything goes public.

## Use

Ask your agent in your own words:

- "save this as a try", "park this somewhere I can find it"
- "graduate this", "make this a real project", "turn this try into a project"
- "make it a proper CLI", "give it a GUI", "make it an Omarchy plugin"

Each run then:

1. **Says where it is**: "on desk, driven from laptop", plus the folder and
   its stage. A folder that has moved to another machine is reported, and work
   stops there.
2. **Picks the flow** from the stage. What you say wins over the default.
3. **Checks the scope.** A conversation that covered several subjects is split
   before anything is made.
4. **Makes the home.** For a try: a dated folder with a README written for
   whoever arrives months later. For a project: a name you pick from checked
   candidates (folder, `PATH`, pacman, AUR, GitHub), `git init`, README,
   `AGENTS.md`, and the code moved in.
5. **Hands over.** It marks the new folder trusted for Claude Code and Codex,
   so a fresh agent does not stop at the trust prompt. It opens the folder as a
   herdr space without taking focus. For a project, it also starts an agent
   there, briefs it, and checks the agent's first answer against what was meant.

Nothing goes to GitHub unless you ask. New repos are private, and nothing goes
public before the whole history is checked for private names and secrets.

## Shapes

A project is **a plugin** (an Omarchy shell plugin, or another host's) or **a
binary**. A binary always has a CLI: subcommands, `--json`, clear exit codes,
and `<name> skill install` for a bundled agent skill. On top of that it can
have a TUI (ratatui), a GUI behind `<name> open`, and a bundled plugin, and
each of them calls the CLI. A plugin can graduate again, into a binary that
keeps the plugin.

Binaries are Rust by default. Go is used only for a stated reason. Existing
projects keep their stack. For a GUI on Omarchy, the choice is made only when a
GUI is actually needed: either a Rust core with a cxx-qt front end, or a C++/Qt
front end built the `omarchy-app` way that calls the CLI's `--json` commands.
See [skill/shapes.md](skill/shapes.md).

## Layout

```
skill/SKILL.md        where am I, which flow, scope, rules
skill/try.md          conversation → try
skill/project.md      try → project
skill/shapes.md       plugin or binary, faces, stack
skill/handover.md     trust, herdr space, agent briefing
skill/scripts/        the helpers the flows call (bash, jq)
  where               host, driving machine, folder, stage
  tries-root          where the tries live
  name-check          is a project name free
  trust               mark a new folder trusted for Claude Code and Codex
  space               open a folder as a herdr space
  handover            start an agent in a space and brief it
install.sh            link the skill into every agent
test/run.sh           script tests in throwaway folders (--live: real herdr and agents)
test/e2e.sh           fresh agents follow the skill in throwaway folders
```

The scripts are thin glue around `jq`, `git` and `herdr`, so they are bash.

## Tests

```bash
test/run.sh            # offline; touches no real config
test/run.sh --live     # also starts claude, codex and pi in throwaway herdr spaces
test/e2e.sh            # claude makes a try and a project; codex picks the skill
```

The live tests and `e2e.sh` add trust entries and herdr spaces for their
throwaway folders, and remove them again at the end. `e2e.sh` keeps each
agent's prompt and answer in `test/e2e-logs/`, which is gitignored.

## Plans

What comes next, and every decision with its reason, lives in the
[issues](https://github.com/lcorneliussen/graduate/issues). Start with the
pinned **Design decisions** issue.

## License

MIT
