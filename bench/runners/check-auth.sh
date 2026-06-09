#!/usr/bin/env bash
# Exit 0 if Claude Code is authenticated for API use.
set -euo pipefail
if claude auth status 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if d.get('loggedIn') else 1)"; then
  exit 0
fi
echo "Claude Code not logged in. Run: claude /login" >&2
exit 1
