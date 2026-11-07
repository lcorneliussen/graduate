#!/usr/bin/env bash
# install.sh [--uninstall]: link the graduate skill into every agent's skills
# folder, the way Omarchy links its own: ~/.agents/skills and ~/.claude/skills
# always, ~/.codex, ~/.pi/agent and ~/.hermes when that agent is set up.
# The links point at this checkout, so a `git pull` updates the skill.
set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)
DIRS=(.agents .claude .codex .pi/agent .hermes)
die() { echo "install.sh: $*" >&2; exit 1; }

case ${1:-} in
  "") mode=install ;;
  --uninstall) mode=uninstall ;;
  *) die "usage: ./install.sh [--uninstall]" ;;
esac

for d in "${DIRS[@]}"; do
  case $d in .agents | .claude) ;; *) [[ -d $HOME/$d ]] || continue ;; esac
  link=$HOME/$d/skills/graduate
  if [[ $mode == uninstall ]]; then
    if [[ -L $link && $(readlink "$link") == "$ROOT/skill" ]]; then rm -- "$link"; echo "removed ~/$d/skills/graduate"; fi
    continue
  fi
  mkdir -p "$HOME/$d/skills"
  if [[ -L $link ]]; then
    [[ $(readlink "$link") == "$ROOT/skill" ]] && { echo "~/$d/skills/graduate: already linked"; continue; }
    die "~/$d/skills/graduate links to $(readlink "$link"); remove it first"
  fi
  [[ -e $link ]] && die "~/$d/skills/graduate exists and is not a link; remove it first"
  ln -s "$ROOT/skill" "$link"
  echo "~/$d/skills/graduate -> $ROOT/skill"
done
