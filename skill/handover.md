# Hand over

The new home gets a herdr space, and for a project an agent of its own. A
fresh agent stops at its folder-trust prompt before it reads a prompt, so the
folder is trusted first.

## 1. Trust the new folder

```bash
"$SKILL_DIR"/scripts/trust <folder>
```

Only for a folder this run created. It sets Claude's
`projects["<folder>"].hasTrustDialogAccepted = true` in `.claude.json` and
adds `[projects."<folder>"]` with `trust_level = "trusted"` to Codex's
`config.toml`. Both files are rewritten by running agents, so it changes one
key and renames a new file into place. It skips an agent that is not set up,
and it is safe to run twice.

## 2. Open it as a herdr space

```bash
"$SKILL_DIR"/scripts/space <folder> [label]
```

The label defaults to the folder's name, which is what sibling spaces use. The
space opens without taking focus: the user is working. It prints the
workspace and pane ids. A space's folder is fixed when it is made; if it is
wrong, close it (`herdr workspace close <id>`) and make it again.

Without a running herdr server, say so and skip this step.

## 3. Start an agent and brief it (projects only)

Write the brief to a file first: what the project is, what was decided and
why, what to do first, and what not to do yet. Then:

```bash
"$SKILL_DIR"/scripts/handover <pane-id> <agent> <brief-file>
```

`<agent>` is `claude`, `codex` or `pi`; use the agent the user is talking to
unless they say otherwise. It starts the agent in the space's pane, sends the
brief, waits for the first answer and prints it.

Check that answer against what was meant. If it misread something, correct it
through `herdr agent prompt <pane-id> "…" --wait`. Then tell the user which
space it is in.

Keep the brief and the answer: the brief goes into the project's
`HANDOVER.local.md`, so the handover can be checked later.
