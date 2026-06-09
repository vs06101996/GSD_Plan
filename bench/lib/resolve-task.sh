#!/usr/bin/env bash
# Source task resolution: eval "$(bench/lib/resolve-task.sh)"
set -euo pipefail
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
eval "$(python3 "$LIB_DIR/resolve_task.py" --shell)"
