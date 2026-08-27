#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/common.sh"

TARGET=""
FORCE=0
MODULES=()

usage() {
  cat <<'EOF'
Usage:
  scripts/apply-template.sh --target PATH --name NAME [options]

Options:
  --repo NAME                 Repository slug. Defaults to kebab-case --name.
  --github-owner OWNER        GitHub owner. Defaults to simonholmes001.
  --github-owner-id ID        Optional immutable GitHub owner numeric ID for Azure OIDC.
  --github-repo-id ID         Optional immutable GitHub repository numeric ID for Azure OIDC.
  --github-ref REF            GitHub ref allowed to deploy Azure resources. Defaults to refs/heads/main.
  --project-number NUMBER     GitHub Project v2 number for auto-sort workflow.
  --profile PROFILE           repo-only, azure-managed-identity-oidc, azure-app-registration-oidc.
  --module MODULE             Optional overlay. Repeatable. Supported: ios-testflight, backend-function.
  --description TEXT          package.json description.
  --env-prefix PREFIX         Prefix for iOS/App Store environment variables.
  --azure-location LOCATION   Defaults to swedencentral.
  --force                     Overwrite differing template-owned files.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --repo) REPO_NAME="$2"; shift 2 ;;
    --github-owner) GITHUB_OWNER="$2"; shift 2 ;;
    --github-owner-id) GITHUB_OWNER_ID="$2"; shift 2 ;;
    --github-repo-id) GITHUB_REPO_ID="$2"; shift 2 ;;
    --github-ref) GITHUB_REF="$2"; shift 2 ;;
    --project-number) PROJECT_NUMBER="$2"; shift 2 ;;
    --profile) PROFILE="$2"; shift 2 ;;
    --module) MODULES+=("$2"); shift 2 ;;
    --description) PROJECT_DESCRIPTION="$2"; shift 2 ;;
    --env-prefix) ENV_PREFIX="$2"; shift 2 ;;
    --azure-location) AZURE_LOCATION="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TARGET" ] || die "--target is required"
TARGET="$(absolute_path "$TARGET")"
mkdir -p "$TARGET"

MODULE_LIST="$(module_list_yaml ${MODULES[@]+"${MODULES[@]}"})"
prepare_context

info "Applying template to $TARGET"
info "Profile: $PROFILE"
if [ -n "${MODULES[*]-}" ]; then
  info "Modules: ${MODULES[*]}"
fi

while IFS= read -r overlay; do
  copy_overlay "$overlay" "$TARGET" apply "$FORCE"
done < <(selected_overlays ${MODULES[@]+"${MODULES[@]}"})

info "Done"
