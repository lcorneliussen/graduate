#!/usr/bin/env bash
# test/e2e.sh: fresh agents follow the installed graduate skill in throwaway
# folders. Needs ./install.sh, a running herdr server, and signed-in agents.
#   A  claude: a conversation becomes a try          (its tries root is a temp folder)
#   B  claude: a try becomes a project               (its ~/Work is a temp folder)
#   C  codex:  picks the graduate skill for "save this as a try"
# Each agent's prompt and answer go to test/e2e-logs/ (gitignored: they name
# this machine). Spaces and trust entries made for the temp folders are removed.
set -uo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)
LOG=$ROOT/test/e2e-logs/$(date +%Y%m%d-%H%M%S); mkdir -p "$LOG"
T=$(mktemp -d "${TMPDIR:-/tmp}/graduate-e2e.XXXXXX")
fails=0 passes=0
ok() { passes=$((passes + 1)); echo "ok   $1"; }
no() { fails=$((fails + 1)); echo "FAIL $1"; }
expect() { local name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else no "$name"; fi; }
ask() { # ask <name> <cwd> <prompt> [env...]: run claude -p, keep prompt and answer
  local name=$1 cwd=$2 prompt=$3; shift 3
  printf '%s\n' "$prompt" >"$LOG/$name.prompt"
  (cd "$cwd" && env "$@" timeout 900 claude -p --permission-mode auto "$prompt") >"$LOG/$name.answer" 2>&1
}
cleanup() {
  for ws in $(herdr workspace list 2>/dev/null | jq -r --arg t "$T" '.result.workspaces[] | .workspace_id' ); do
    cwd=$(herdr api snapshot 2>/dev/null | jq -r --arg w "$ws" '[.. | objects | select(has("pane_id") and .workspace_id == $w)][0].cwd // empty')
    [[ $cwd == "$T"/* ]] && herdr workspace close "$ws" >/dev/null && echo "closed space $ws ($cwd)"
  done
  c=${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json; tmp=$(mktemp "$c.graduate.XXXXXX")
  jq --arg t "$T/" '.projects |= with_entries(select(.key | startswith($t) | not))' "$c" >"$tmp" && chmod --reference="$c" "$tmp" && mv -f "$tmp" "$c"
  x=${CODEX_HOME:-$HOME/.codex}/config.toml; tmp=$(mktemp "$x.graduate.XXXXXX")
  awk -v t="[projects.\"$T/" 'index($0,t)==1{s=1;next} s&&/^\[/{s=0} !s' "$x" | cat -s >"$tmp" && chmod --reference="$x" "$tmp" && mv -f "$tmp" "$x"
  rm -rf "$T"
}
trap cleanup EXIT

# --- A: conversation -> try -----------------------------------------------
mkdir -p "$T/tries/2026-01-01-seed" "$T/conv" "$T/live"
printf '#!/bin/sh\necho "volume at $(date +%%H:%%M)"\n' >"$T/live/vol-notify.sh"
ask A-try "$T/conv" "Earlier in this conversation we wrote $T/live/vol-notify.sh, a script that prints the volume with the time, and found that it must be called with sh, not bash, because of a quirk we did not fully understand. Now: save this conversation as a try. The user is not available for questions: assume yes to anything you would ask, and do not start an agent in the new space." GRADUATE_TRIES_ROOT="$T/tries"
new=$(find "$T/tries" -mindepth 1 -maxdepth 1 -type d -name '20*' ! -name '2026-01-01-seed' | head -1)
expect "A: a new dated try folder" test -n "$new"
expect "A: named YYYY-MM-DD-<subject> with today's date" bash -c "[[ \$(basename '$new') == $(date +%F)-* ]]"
expect "A: README.md written" test -s "$new/README.md"
expect "A: the live script is linked, not copied" bash -c "find '$new' -type l -lname '*vol-notify.sh' | grep -q ."
expect "A: the README mentions the sh quirk" grep -qi 'sh' "$new/README.md"
expect "A: the answer says which machine" grep -q "$(hostname)" "$LOG/A-try.answer"
expect "A: a herdr space on the try" bash -c "herdr api snapshot | jq -r '.. | objects | select(has(\"pane_id\")) | .cwd' | grep -qx '$new'"

# --- B: try -> project ----------------------------------------------------
try=$T/tries/2026-01-01-seed
cat >"$try/wordcount.py" <<'PY'
import sys
print(sum(len(l.split()) for l in open(sys.argv[1])))
PY
printf '# Word count\n\nCounts the words in a file: `python wordcount.py <file>`.\n' >"$try/README.md"
mkdir -p "$T/work"
ask B-project "$try" "Graduate this try into a project. The user already picked the name zqgrad-demo. Do not create a GitHub repo, do not port the stack yet, and do not start an agent in the handover; do trust the folder and open the space. The user is not available for questions: assume yes otherwise." GRADUATE_TRIES_ROOT="$T/tries" GRADUATE_WORK_ROOT="$T/work"
P=$T/work/zqgrad-demo
expect "B: the project folder is a git repo" git -C "$P" rev-parse --git-dir
expect "B: it has a commit" git -C "$P" log -1
expect "B: the code was moved in" bash -c "git -C '$P' ls-files | grep -q wordcount"
expect "B: README links back to the try" grep -q "2026-01-01-seed" "$P/README.md"
expect "B: AGENTS.md written" test -s "$P/AGENTS.md"
expect "B: .gitignore keeps *.local.md out" grep -qF '*.local.md' "$P/.gitignore"
expect "B: the try says where it graduated to" grep -qi "graduated" "$try/README.md"
expect "B: no GitHub remote" bash -c "[[ -z \$(git -C '$P' remote) ]]"
expect "B: claude trusts the folder" bash -c "[[ \$(jq --arg p '$P' '.projects[\$p].hasTrustDialogAccepted' ${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json) == true ]]"
expect "B: a herdr space on the project" bash -c "herdr api snapshot | jq -r '.. | objects | select(has(\"pane_id\")) | .cwd' | grep -qx '$P'"

# --- C: codex picks the skill ---------------------------------------------
p="Which of your installed skills would you use if the user said: 'save this conversation as a try'? Answer with the skill's name only."
printf '%s\n' "$p" >"$LOG/C-codex.prompt"
(cd "$T/conv" && timeout 300 codex exec --skip-git-repo-check "$p") >"$LOG/C-codex.answer" 2>&1
expect "C: codex names graduate" grep -qiw graduate <(tail -5 "$LOG/C-codex.answer")

echo "$passes passed, $fails failed (logs: $LOG)"
((fails == 0))
