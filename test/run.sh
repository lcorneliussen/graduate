#!/usr/bin/env bash
# test/run.sh [--live]: test the skill's scripts in throwaway folders.
#   default   trust, tries-root, where, name-check, skill layout; touches no real config
#   --live    (agents: $GRADUATE_LIVE_AGENTS, default "claude codex pi") also opens a herdr space on a throwaway folder, starts each agent
#             (claude, codex, pi) there with a one-line brief, and closes it again
set -uo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)
S=$ROOT/skill/scripts
T=$(mktemp -d "${TMPDIR:-/tmp}/graduate-test.XXXXXX")
trap 'rm -rf "$T"' EXIT
fails=0 passes=0
ok() { passes=$((passes + 1)); echo "ok   $1"; }
no() { fails=$((fails + 1)); echo "FAIL $1"; [[ -n ${2:-} ]] && sed 's/^/     /' <<<"$2"; }
check() { local name=$1; shift; if out=$("$@" 2>&1); then ok "$name"; else no "$name" "$out"; fi; }

# --- skill layout ---------------------------------------------------------
check "SKILL.md has name: graduate" grep -qx 'name: graduate' "$ROOT/skill/SKILL.md"
for f in $(grep -ohP '\]\(\K[a-z]+\.md(?=\))' "$ROOT"/skill/*.md | sort -u); do
  check "link target skill/$f exists" test -f "$ROOT/skill/$f"
done
for f in $(grep -ohP '"\$SKILL_DIR"/scripts/\K[a-z-]+' "$ROOT"/skill/*.md | sort -u); do
  check "script $f exists and is executable" test -x "$S/$f"
done

# --- trust ----------------------------------------------------------------
dir=$T/work/newhome; mkdir -p "$dir" "$T/codex"
printf '{"projects":{"/other":{"hasTrustDialogAccepted":false,"x":1}},"keep":true}\n' >"$T/claude.json"
chmod 600 "$T/claude.json"
printf 'model = "m"\n\n[projects."/other"]\ntrust_level = "untrusted"\n' >"$T/codex/config.toml"
export GRADUATE_CLAUDE_JSON=$T/claude.json GRADUATE_CODEX_TOML=$T/codex/config.toml
check "trust: runs" "$S/trust" "$dir"
check "trust: claude key set" test "$(jq --arg p "$dir" '.projects[$p].hasTrustDialogAccepted' "$T/claude.json")" = true
check "trust: claude other keys kept" test "$(jq -c '[.keep, .projects["/other"]]' "$T/claude.json")" = '[true,{"hasTrustDialogAccepted":false,"x":1}]'
check "trust: claude mode kept" test "$(stat -c %a "$T/claude.json")" = 600
check "trust: codex section added" grep -qxF "[projects.\"$dir\"]" "$T/codex/config.toml"
check "trust: codex other sections kept" grep -qx 'trust_level = "untrusted"' "$T/codex/config.toml"
cp "$T/codex/config.toml" "$T/before.toml"
check "trust: second run is a no-op" "$S/trust" "$dir"
check "trust: codex not duplicated" cmp -s "$T/codex/config.toml" "$T/before.toml"
check "trust: no temp files left" test -z "$(find "$T" -name '*.graduate.*')"
mkdir -p "$T/other-home"
printf '\n[projects."%s"]\ntrust_level = "untrusted"\n' "$T/other-home" >>"$T/codex/config.toml"
if "$S/trust" "$T/other-home" >/dev/null 2>&1; then no "trust: leaves an explicit untrusted alone"; else ok "trust: leaves an explicit untrusted alone"; fi
if "$S/trust" "$HOME" >/dev/null 2>&1; then no "trust: refuses \$HOME"; else ok "trust: refuses \$HOME"; fi
if "$S/trust" "$T/missing" >/dev/null 2>&1; then no "trust: refuses a missing folder"; else ok "trust: refuses a missing folder"; fi
rm "$T/claude.json"
check "trust: skips a missing claude config" bash -c "'$S/trust' '$dir' | grep -q 'claude: skipped'"
unset GRADUATE_CLAUDE_JSON GRADUATE_CODEX_TOML

# --- tries-root and where -------------------------------------------------
mkdir -p "$T/tries/2026-01-02-some-subject/sub" "$T/empty"
check "tries-root: GRADUATE_TRIES_ROOT wins" test "$(GRADUATE_TRIES_ROOT=$T/tries "$S/tries-root")" = "$T/tries"
if GRADUATE_TRIES_ROOT=$T/empty HOME=$T/empty GRADUATE_SKIP_HERDR=1 TRY_PATH= "$S/tries-root" >/dev/null 2>&1; then no "tries-root: fails without tries"; else ok "tries-root: fails without tries"; fi
export GRADUATE_TRIES_ROOT=$T/tries GRADUATE_EMIGRATED_LOG=$T/emigrated.jsonl
w() { "$S/where" "$1" | sed -n 's/^stage:  //p'; }
check "where: says the host" bash -c "'$S/where' '$T' | head -1 | grep -q '^on $(hostname), driven from '"
check "where: a try" bash -c "[[ '$(w "$T/tries/2026-01-02-some-subject/sub")' == try:* ]]"
git -C "$T/work/newhome" init -q
check "where: a project" bash -c "[[ '$(w "$T/work/newhome")' == project:* ]]"
check "where: a conversation" bash -c "[[ '$(w "$T/empty")' == conversation:* ]]"
echo "{\"date\":\"2026-01-03\",\"stage\":\"try\",\"from\":\"$T/tries/2026-01-02-some-subject\",\"to_machine\":\"desk\",\"to_path\":\"/home/u/Work/tries/2026-01-02-some-subject\"}" >"$T/emigrated.jsonl"
check "where: an emigrated try" bash -c "[[ '$(w "$T/tries/2026-01-02-some-subject/sub")' == 'emigrated: moved to desk:'* ]]"
unset GRADUATE_TRIES_ROOT GRADUATE_EMIGRATED_LOG

# --- name-check -----------------------------------------------------------
mkdir -p "$T/work/takenname"
check "name-check: a folder clash" bash -c "GRADUATE_WORK_ROOT='$T/work' '$S/name-check' takenname | grep -q 'taken (folder'"
check "name-check: a command clash" bash -c "GRADUATE_WORK_ROOT='$T/work' '$S/name-check' bash | grep -q 'command'"
check "name-check: a free name" bash -c "GRADUATE_WORK_ROOT='$T/work' '$S/name-check' zq-graduate-free-$$ | grep -q ': free'"

# --- live: herdr space and agent handover ---------------------------------
if [[ ${1:-} == --live ]]; then
  for kind in ${GRADUATE_LIVE_AGENTS:-claude codex pi}; do
    home=$T/live-$kind; mkdir -p "$home"
    "$S/trust" "$home" >/dev/null   # the real config; removed again below
    out=$("$S/space" "$home" "graduate-test-$kind" 2>&1) || { no "live $kind: space" "$out"; continue; }
    ws=$(awk '/^workspace /{print $2}' <<<"$out"); pane=$(awk '/^pane /{print $2}' <<<"$out")
    ok "live $kind: space $ws"
    echo "Reply with exactly the word GRADUATED and nothing else. Do not run any tools." >"$T/brief"
    sleep 2
    if ans=$(GRADUATE_HANDOVER_TIMEOUT=180000 "$S/handover" "$pane" "$kind" "$T/brief" "graduate-test" 2>&1) && grep -q GRADUATED <<<"$(grep -v 'Reply with exactly' <<<"$ans")"; then
      ok "live $kind: agent answered the brief"
    else
      no "live $kind: agent answered the brief" "$(tail -40 <<<"$ans")"
    fi
    herdr workspace close "$ws" >/dev/null 2>&1
    # Undo the trust entries for the throwaway folder.
    c=${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json; tmp=$(mktemp "$c.graduate.XXXXXX")
    jq --arg p "$home" 'del(.projects[$p])' "$c" >"$tmp" && chmod --reference="$c" "$tmp" && mv -f "$tmp" "$c"
    x=${CODEX_HOME:-$HOME/.codex}/config.toml; tmp=$(mktemp "$x.graduate.XXXXXX")
    awk -v h="[projects.\"$home\"]" '$0==h{s=1;next} s&&/^\[/{s=0} !s' "$x" | cat -s >"$tmp" && chmod --reference="$x" "$tmp" && mv -f "$tmp" "$x"
  done
fi

echo "$passes passed, $fails failed"
((fails == 0))
