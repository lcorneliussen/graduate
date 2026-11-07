# Shapes and faces

A project takes one of two shapes. Agree it with the user; it decides the
stack.

## A plugin

An Omarchy shell plugin, or another host's. Build it with the `omarchy`
skill's plugin guide (`plugins.md` in that skill) and try it in an omabox box.
A plugin is not a binary, so the stack rule below does not apply to it.

A plugin can graduate again, into a binary: it then keeps the plugin as a
bundled face that calls the binary's CLI.

## A binary, with faces

| Face | When | How |
|---|---|---|
| **CLI** | always | subcommands, `--json`, exit 0 or 1 with errors on stderr, `<name> skill install` |
| **TUI** | optional | ratatui, behind `<name>` with no arguments or `<name> tui` |
| **GUI** | optional | behind `<name> open`, tried in omabox |
| **Bundled plugin** | optional | the plugin it grew from, or one that shows its state in the bar; it calls the CLI |

**The CLI comes first.** It is what lets agents drive the tool, and the
contract every other face calls. This is Hype's pattern, which the
`omarchy-app` skill asks for whenever an app makes or changes files: commands
that need no display, each with `--json`, and a short agent skill bundled in the
binary that `<name> skill install` installs.

## Stack

- **Rust** by default, for the CLI and the TUI (ratatui).
- **Go** only with a reason you state, such as a library that exists only in
  Go.
- **Existing projects keep their stack** unless the user asks.
- Rust also because a GUI may come later: Rust can drive a QML front end in the
  same process (cxx-qt), while Go's Qt bindings are weak and its own toolkits
  do not look native on Omarchy.

When a GUI is actually needed, and not before, choose with the user between:

1. a Rust core with a cxx-qt front end, in one binary. This leaves the
   `omarchy-app` skill's path (its templates, tests and packaging);
2. a C++/Qt front end built the `omarchy-app` way, calling the Rust CLI's
   `--json` commands, so each side follows its own skill.

The CLI contract keeps both open. Neither has been tried here yet; say so when
you propose one.

## Changing a project's shape

Called from a project, work on a branch, not in a new folder. Adding a face
does not change the stack. A new GUI is the one moment the choice above is made.
