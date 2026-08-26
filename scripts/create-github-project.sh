#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/common.sh"

TITLE=""
OWNER="simonholmes001"

usage() {
  cat <<'EOF'
Usage:
  scripts/create-github-project.sh --title TITLE [--owner OWNER]

Creates a GitHub Project v2 board with the standard Status and Priority fields.
Requires gh auth with the project scope.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --owner) OWNER="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$TITLE" ] || die "--title is required"

gh auth status -h github.com >/dev/null

existing="$(gh project list --owner "$OWNER" --format json | jq -r --arg title "$TITLE" '.projects[] | select(.title == $title) | .number' | head -1)"
if [ -n "$existing" ]; then
  info "Project already exists: $TITLE (#$existing)"
  number="$existing"
else
  number="$(gh project create --owner "$OWNER" --title "$TITLE" --format json | jq -r '.number')"
  info "Created project: $TITLE (#$number)"
fi

fields_json="$(gh project field-list "$number" --owner "$OWNER" --format json)"

if ! echo "$fields_json" | jq -e '.fields[] | select(.name == "Status")' >/dev/null; then
  gh project field-create "$number" \
    --owner "$OWNER" \
    --name "Status" \
    --data-type SINGLE_SELECT \
    --single-select-options "Backlog,Ready,In Progress,Done" >/dev/null
  info "Added Status field"
else
  info "Status field already exists"
fi

if ! echo "$fields_json" | jq -e '.fields[] | select(.name == "Priority")' >/dev/null; then
  gh project field-create "$number" \
    --owner "$OWNER" \
    --name "Priority" \
    --data-type SINGLE_SELECT \
    --single-select-options "P0,P1,P2" >/dev/null
  info "Added Priority field"
else
  info "Priority field already exists"
fi

info "Check the board fields with: gh project field-list $number --owner $OWNER"
info "Set repository variables for auto-sort:"
echo "PROJECT_OWNER=$OWNER"
echo "PROJECT_NUMBER=$number"
