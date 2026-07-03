#!/usr/bin/env bash
# Convenience runner: validate all skills, agents, and workflows in one pass.
# Usage: scripts/validate_all.sh
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

overall_rc=0

"$SCRIPT_DIR/validate_skill.sh"; rc=$?; [ "$rc" -ne 0 ] && overall_rc=1

"$SCRIPT_DIR/validate_agent.sh"; rc=$?; [ "$rc" -ne 0 ] && overall_rc=1

"$SCRIPT_DIR/validate_workflow.sh"; rc=$?; [ "$rc" -ne 0 ] && overall_rc=1

echo ""
if [ "$overall_rc" -eq 0 ]; then
  echo "All skills, agents, and workflows passed validation (warnings may still be present above)."
else
  echo "One or more skills, agents, or workflows FAILED validation - see above."
fi
exit $overall_rc
