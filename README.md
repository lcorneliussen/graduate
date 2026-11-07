# graduate

Take work from wherever it is — a loose agent conversation, a dated try folder,
a script that quietly became load-bearing — to a proper project: named, in its
own folder, git managed, on GitHub when it may be public, and on a stack meant
to last. And move work between machines at any stage without losing track of
where it lives.

Nothing is built yet. The plan and its decisions live in the
repo's issues (start with the pinned **Design decisions**); the rules for
working on it are in [AGENTS.md](AGENTS.md).

## The idea in one table

| Stage | Lives in | Graduates to |
|---|---|---|
| Conversation | an agent's session store | a try, or straight to a project when it is clearly one thing |
| Try | `~/Work/tries/YYYY-MM-DD-<subject>/`, no git | a project, once it holds code that runs on the machine |
| Project | `~/Work/<name>/`, git | a proper CLI, plugin or app, public when nothing private is in it |

Every project also has a **home**: *homed* (it lives on one machine and is
reached remotely from the others) or *synced* (a checkout on every machine,
kept in step through GitHub). Not knowing which is the main source of "it
works here, why not there".

## Parts

- **Skill** (first): one `graduate` skill. It works out where it is called
  from and takes the work one stage up: a conversation becomes a try (a
  permanent dated folder, no naming fuss), a try becomes a named project, and a
  project gets its shape: a CLI, a plugin or an app. It clarifies scope when a
  conversation covered more than one thing.
- **CLI** `graduate` (later), in Rust with ratatui: `status`, `move <machine>`
  (emigrate), `graduate`, `open`. It calls agent CLIs for judgement: naming,
  privacy review, "is this ready", porting a stack.
- **Privacy gate**: a pre-push hook that refuses a public push containing names
  that must stay private.

graduate stands alone. When [omaego](https://github.com/lcorneliussen/omaego)
is installed it uses it — machine names, which ego a project belongs to, the
private names to keep out of public repos, opening a homed project remotely —
but it never needs it.
