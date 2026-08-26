#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/common.sh"

usage() {
  cat <<'EOF'
Usage:
  scripts/update-project.sh --target PATH --name NAME [options]

Wrapper around apply-template.sh that overwrites differing template-owned files.
Use from a feature branch in the target repo so the result is reviewable.
EOF
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

"$SCRIPT_DIR/apply-template.sh" "$@" --force

