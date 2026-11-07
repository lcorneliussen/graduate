# graduate

Take work from wherever it is — a loose agent conversation, a dated try folder,
a script that quietly became load-bearing — to a proper project: named, in its
own folder, git managed, on GitHub when it may be public, and on a stack meant
to last. And move work between machines at any stage without losing track of
where it lives.

Nothing is built yet. This repo holds the plan ([docs/plan.md](docs/plan.md))
and the rules for working on it ([AGENTS.md](AGENTS.md)).

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

- **Skills** (first): `graduate-try`, `graduate-project`, `graduate-cli`,
  `graduate-plugin`, `graduate-app`. Each first detects where it is called from
  (a try, an unrelated conversation, a project) and follows that flow; each
  clarifies scope when a conversation covered more than one thing, and helps
  find a name on the spot.
- **CLI** `graduate` (later), in Rust with ratatui: `status`, `move <machine>`
  (emigrate), `graduate`, `open`. It calls agent CLIs for judgement: naming,
  privacy review, "is this ready", porting a stack.
- **Privacy gate**: a pre-push hook that refuses a public push containing names
  that must stay private.

graduate stands alone. When [omaego](https://github.com/lcorneliussen/omaego)
is installed it uses it — machine names, which ego a project belongs to, the
private names to keep out of public repos, opening a homed project remotely —
but it never needs it.
