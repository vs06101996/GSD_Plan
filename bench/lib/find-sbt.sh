#!/usr/bin/env bash
# Resolve sbt executable: SBT, PATH, or Homebrew.
set -euo pipefail

if [[ -n "${SBT:-}" && -x "${SBT}" ]]; then
  echo "$SBT"
  exit 0
fi

if command -v sbt >/dev/null 2>&1; then
  command -v sbt
  exit 0
fi

for candidate in \
  "${HOMEBREW_PREFIX:-}/bin/sbt" \
  "/opt/homebrew/bin/sbt" \
  "/usr/local/bin/sbt"; do
  if [[ -x "$candidate" ]]; then
    echo "$candidate"
    exit 0
  fi
done

echo "error: sbt not found. Install sbt (e.g. brew install sbt) or set SBT=/path/to/sbt" >&2
exit 1
