# Try → project

Called from a try, the user wants an actual project: its own folder, git, a
real name, and a stack meant to last. Also the way in when a conversation's
work is clearly one thing and started as code; then there is no try to link.

## 1. Name it, properly

A project name lasts, so find it with the user, on the spot:

1. Propose three to five short names, lowercase, one word where possible.
   Ask a second agent for ideas if you like; keep its prompt and answer in the
   README's history section.
2. Check each one before offering it:
   ```bash
   "$SKILL_DIR"/scripts/name-check <name>…
   ```
   It reports a clash with an existing `~/Work/<name>`, a command on `PATH`, a
   pacman or AUR package, and a GitHub repo under the user's account.
3. The user picks. Never pick for them.

## 2. Make the folder

```bash
P=${GRADUATE_WORK_ROOT:-$HOME/Work}/<name>
mkdir "$P" && git -C "$P" init -q -b master
```

`mkdir` without `-p`: it must fail if the folder exists. Then move the work in:

- **Code** is copied from the try (or from where it runs today) and committed.
  Live files that the try only linked to stay where they are for now; say
  which ones, and that installing from the project replaces them later.
- **A README** that says what it is, how to run it, and where it grew from:
  a link to the try folder and the conversation's session file.
- **An `AGENTS.md`** with what an agent needs that the README does not say.
  Start it with the rules the try learned the hard way.
- **A `.gitignore`** with `*.local.md`: machine-specific notes go in
  `HANDOVER.local.md` and similar, never in git.

The try stays as it is. Add a line to its README: "graduated to `~/Work/<name>`
on <date>".

## 3. Give it a shape

Read [shapes.md](shapes.md) and agree the shape with the user: a plugin, or a
binary whose CLI comes first. If the try's code is in a quick-check language
(Python, Ruby, a long bash script), porting it to the stack is part of
graduating. Do it after the first commit, so the original is in history.

## 4. GitHub, only when asked

Ask before creating a repo. When the user says yes:

```bash
gh repo create <owner>/<name> --private --source "$P" --push
```

**Private always**, unless the user says public. Before anything goes public,
check the whole history, not only the diff, for names that must stay private:
real machine, person, customer, tenant and host names, and secrets. Run
`gitleaks git "$P"` when gitleaks is installed; read `git log -p` yourself
either way. Use invented names in anything public (machines like box, laptop
and desk; hosts under `example.com`).

## 5. Hand over

[handover.md](handover.md), with an agent: the new project gets a space and an
agent of its own, briefed on what was meant.
