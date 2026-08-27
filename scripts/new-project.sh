#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/common.sh"

DESTINATION=""
INIT_GIT=1
CREATE_GITHUB=0
PRIVATE_FLAG="--private"
MODULES=()

usage() {
  cat <<'EOF'
Usage:
  scripts/new-project.sh --name NAME --destination PATH [options]

Creates a local repository folder and applies the selected template overlays.

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
  --create-github            Also create the GitHub repository with gh.
  --public                   Use with --create-github to create a public repo.
  --no-git                   Do not run git init.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --destination) DESTINATION="$2"; shift 2 ;;
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
    --create-github) CREATE_GITHUB=1; shift ;;
    --public) PRIVATE_FLAG="--public"; shift ;;
    --no-git) INIT_GIT=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$DESTINATION" ] || die "--destination is required"
MODULE_LIST="$(module_list_yaml ${MODULES[@]+"${MODULES[@]}"})"
prepare_context

DESTINATION="$(absolute_path "$DESTINATION")"
if [ -e "$DESTINATION" ] && [ "$(find "$DESTINATION" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" != "0" ]; then
  die "destination exists and is not empty: $DESTINATION"
fi

mkdir -p "$DESTINATION"

if [ "$INIT_GIT" = "1" ]; then
  git -C "$DESTINATION" init
fi

apply_args=(
  --target "$DESTINATION"
  --name "$PROJECT_NAME"
  --repo "$REPO_NAME"
  --github-owner "$GITHUB_OWNER"
  --github-owner-id "$GITHUB_OWNER_ID"
  --github-repo-id "$GITHUB_REPO_ID"
  --github-ref "$GITHUB_REF"
  --project-number "$PROJECT_NUMBER"
  --profile "$PROFILE"
  --description "$PROJECT_DESCRIPTION"
  --env-prefix "$ENV_PREFIX"
  --azure-location "$AZURE_LOCATION"
)

for module in ${MODULES[@]+"${MODULES[@]}"}; do
  apply_args+=(--module "$module")
done

"$SCRIPT_DIR/apply-template.sh" "${apply_args[@]}"

if [ ! -f "$DESTINATION/README.md" ]; then
  {
    echo "# $PROJECT_NAME"
    echo
    echo "$PROJECT_DESCRIPTION"
  } > "$DESTINATION/README.md"
fi

if [ "$CREATE_GITHUB" = "1" ]; then
  gh repo create "$GITHUB_OWNER/$REPO_NAME" "$PRIVATE_FLAG" --source "$DESTINATION" --remote origin
fi

info "New project created at $DESTINATION"
info "Next: cd $DESTINATION && scripts/setup-hooks.sh && git status"
