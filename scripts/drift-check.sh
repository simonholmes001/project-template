#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/common.sh"

TARGET=""
MODULES=()

usage() {
  cat <<'EOF'
Usage:
  scripts/drift-check.sh --target PATH --name NAME [options]

Reports files that are missing or different from the rendered template.
It does not write to the target repository.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --repo) REPO_NAME="$2"; shift 2 ;;
    --github-owner) GITHUB_OWNER="$2"; shift 2 ;;
    --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --module) MODULES+=("$2"); shift 2 ;;
    --description) PROJECT_DESCRIPTION="$2"; shift 2 ;;
    --env-prefix) ENV_PREFIX="$2"; shift 2 ;;
    --azure-location) AZURE_LOCATION="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TARGET" ] || die "--target is required"
[ -d "$TARGET" ] || die "target does not exist: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

MODULE_LIST="$(module_list_yaml ${MODULES[@]+"${MODULES[@]}"})"
prepare_context

info "Checking drift for $TARGET"
while IFS= read -r overlay; do
  copy_overlay "$overlay" "$TARGET" check 0
done < <(selected_overlays ${MODULES[@]+"${MODULES[@]}"})
