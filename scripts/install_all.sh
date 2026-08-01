#!/usr/bin/env bash
# Convenience runner: link all skills and agents into the pi harness in one pass.
# Mirrors validate_all.sh.
#
# Usage:
#   install_all.sh [flags...]     # flags are forwarded to both sub-scripts
#
# Common:
#   install_all.sh                # link everything (public skills + agents)
#   install_all.sh --check        # report drift only, change nothing; exit 1 if out of sync
#   install_all.sh --prune        # also remove broken links pointing into this repo
#
# Flags accepted by only one sub-script (--thirdparty for skills, --private for
# agents) are passed to the one that understands them and dropped for the other.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

skill_args=(); agent_args=()
for arg in "$@"; do
  case "$arg" in
    --thirdparty) skill_args+=("$arg") ;;
    --private)    agent_args+=("$arg") ;;
    *)            skill_args+=("$arg"); agent_args+=("$arg") ;;
  esac
done

overall_rc=0

"$SCRIPT_DIR/install_skills.sh" ${skill_args[@]+"${skill_args[@]}"}; rc=$?
[ "$rc" -ne 0 ] && overall_rc=1

"$SCRIPT_DIR/install_agents.sh" ${agent_args[@]+"${agent_args[@]}"}; rc=$?
[ "$rc" -ne 0 ] && overall_rc=1

echo ""
if [ "$overall_rc" -eq 0 ]; then
  echo "All skills and agents are linked into the pi harness."
else
  echo "Skills/agents are out of sync or an error occurred - see above."
fi
exit $overall_rc
