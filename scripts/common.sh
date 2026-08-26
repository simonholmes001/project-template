#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

die() {
  echo "error: $*" >&2
  exit 1
}

info() {
  echo "==> $*"
}

kebab_case() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

underscore_case() {
  printf '%s' "$1" \
    | tr '[:lower:]' '[:upper:]' \
    | sed -E 's/[^A-Z0-9]+/_/g; s/^_+//; s/_+$//'
}

pascal_case() {
  printf '%s' "$1" \
    | awk '
      {
        n = split($0, parts, /[^[:alnum:]]+/)
        out = ""
        for (i = 1; i <= n; i++) {
          if (parts[i] == "") continue
          out = out toupper(substr(parts[i], 1, 1)) tolower(substr(parts[i], 2))
        }
        print out
      }
    '
}

absolute_path() {
  local path="$1"
  local dir base
  dir="$(dirname "$path")"
  base="$(basename "$path")"
  mkdir -p "$dir"
  dir="$(cd "$dir" && pwd)"
  printf '%s/%s\n' "$dir" "$base"
}

module_list_yaml() {
  if [ "$#" -eq 0 ]; then
    echo "  []"
    return
  fi

  local module
  for module in "$@"; do
    echo "  - $module"
  done
}

render_stream() {
  perl -pe '
    s/\{\{PROJECT_NAME\}\}/$ENV{PROJECT_NAME}/g;
    s/\{\{PROJECT_NAME_UPPER\}\}/$ENV{PROJECT_NAME_UPPER}/g;
    s/\{\{PROJECT_NAME_PASCAL\}\}/$ENV{PROJECT_NAME_PASCAL}/g;
    s/\{\{PROJECT_DESCRIPTION\}\}/$ENV{PROJECT_DESCRIPTION}/g;
    s/\{\{REPO_NAME\}\}/$ENV{REPO_NAME}/g;
    s/\{\{REPO_NAME_UNDERSCORE\}\}/$ENV{REPO_NAME_UNDERSCORE}/g;
    s/\{\{GITHUB_OWNER\}\}/$ENV{GITHUB_OWNER}/g;
    s/\{\{PROJECT_NUMBER\}\}/$ENV{PROJECT_NUMBER}/g;
    s/\{\{ENV_PREFIX\}\}/$ENV{ENV_PREFIX}/g;
    s/\{\{AZURE_LOCATION\}\}/$ENV{AZURE_LOCATION}/g;
    s/\{\{PROFILE\}\}/$ENV{PROFILE}/g;
    s/\{\{MODULE_LIST\}\}/$ENV{MODULE_LIST}/g;
    s/\{\{APPLIED_AT\}\}/$ENV{APPLIED_AT}/g;
  '
}

prepare_context() {
  PROJECT_NAME="${PROJECT_NAME:-}"
  REPO_NAME="${REPO_NAME:-}"
  GITHUB_OWNER="${GITHUB_OWNER:-simonholmes001}"
  PROJECT_NUMBER="${PROJECT_NUMBER:-}"
  AZURE_LOCATION="${AZURE_LOCATION:-westeurope}"
  PROFILE="${PROFILE:-repo-only}"
  PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-$PROJECT_NAME project foundation}"

  [ -n "$PROJECT_NAME" ] || die "--name is required"
  [ -n "$REPO_NAME" ] || REPO_NAME="$(kebab_case "$PROJECT_NAME")"

  PROJECT_NAME_UPPER="$(underscore_case "$PROJECT_NAME")"
  PROJECT_NAME_PASCAL="$(pascal_case "$PROJECT_NAME")"
  REPO_NAME_UNDERSCORE="$(underscore_case "$REPO_NAME")"
  ENV_PREFIX="${ENV_PREFIX:-$PROJECT_NAME_UPPER}"
  APPLIED_AT="${APPLIED_AT:-$(date -u '+%Y-%m-%dT%H:%M:%SZ')}"

  export PROJECT_NAME PROJECT_NAME_UPPER PROJECT_NAME_PASCAL PROJECT_DESCRIPTION
  export REPO_NAME REPO_NAME_UNDERSCORE GITHUB_OWNER ENV_PREFIX AZURE_LOCATION
  export PROJECT_NUMBER PROFILE MODULE_LIST APPLIED_AT
}

overlay_path() {
  local overlay="$1"
  local path="$TEMPLATE_ROOT/template/$overlay"
  [ -d "$path" ] || die "unknown overlay: $overlay"
  printf '%s\n' "$path"
}

render_file_to_temp() {
  local source="$1"
  local temp="$2"
  render_stream < "$source" > "$temp"
}

copy_overlay() {
  local overlay="$1"
  local target="$2"
  local mode="${3:-apply}"
  local force="${4:-0}"
  local overlay_dir
  overlay_dir="$(overlay_path "$overlay")"

  local source rel destination temp
  while IFS= read -r source; do
    rel="${source#"$overlay_dir"/}"
    destination="$target/$rel"
    temp="$(mktemp)"
    render_file_to_temp "$source" "$temp"

    if [ "$mode" = "check" ]; then
      if [ ! -f "$destination" ]; then
        echo "missing: $rel"
      elif ! cmp -s "$temp" "$destination"; then
        echo "different: $rel"
      fi
      rm -f "$temp"
      continue
    fi

    mkdir -p "$(dirname "$destination")"
    if [ -f "$destination" ] && ! cmp -s "$temp" "$destination" && [ "$force" != "1" ]; then
      echo "conflict: $rel already exists and differs; re-run with --force to overwrite" >&2
      rm -f "$temp"
      return 2
    fi

    cp "$temp" "$destination"
    if [ -x "$source" ]; then
      chmod +x "$destination"
    fi
    rm -f "$temp"
    echo "applied: $rel"
  done < <(find "$overlay_dir" -type f | sort)
}

selected_overlays() {
  echo "base"

  case "$PROFILE" in
    repo-only)
      ;;
    azure-managed-identity-oidc)
      echo "azure-managed-identity-oidc"
      ;;
    azure-app-registration-oidc)
      echo "azure-app-registration-oidc"
      ;;
    *)
      die "unknown profile: $PROFILE"
      ;;
  esac

  local module
  for module in "$@"; do
    case "$module" in
      ios-testflight|backend-function)
        echo "$module"
        ;;
      *)
        die "unknown module: $module"
        ;;
    esac
  done
}
