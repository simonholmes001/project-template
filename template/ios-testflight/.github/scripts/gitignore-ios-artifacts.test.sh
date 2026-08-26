#!/usr/bin/env bash
set -euo pipefail

GITIGNORE=".gitignore"

[ -f "$GITIGNORE" ] || { echo "Missing .gitignore" >&2; exit 1; }

required_patterns=(
  ".worktrees/"
  "ios/.DS_Store"
  "ios/{{PROJECT_NAME_PASCAL}}.xcodeproj/project.xcworkspace/"
  "ios/{{PROJECT_NAME_PASCAL}}.xcodeproj/xcuserdata/"
  "ios/{{PROJECT_NAME_PASCAL}}App/.swiftpm/"
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Fxq "$pattern" "$GITIGNORE"; then
    echo "Missing ignore pattern: $pattern" >&2
    exit 1
  fi
  if [ "$(grep -Fxc "$pattern" "$GITIGNORE")" -ne 1 ]; then
    echo "Ignore pattern must appear exactly once: $pattern" >&2
    exit 1
  fi
done

must_be_ignored=(
  ".worktrees/scratch/file.txt"
  "ios/.DS_Store"
  "ios/{{PROJECT_NAME_PASCAL}}.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
  "ios/{{PROJECT_NAME_PASCAL}}.xcodeproj/xcuserdata/user.xcuserdatad/UserInterfaceState.xcuserstate"
  "ios/{{PROJECT_NAME_PASCAL}}App/.swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata"
)

for path in "${must_be_ignored[@]}"; do
  if ! git check-ignore -q "$path"; then
    echo "Expected path to be ignored: $path" >&2
    exit 1
  fi
done

must_not_be_ignored=(
  "README.md"
  "ios/{{PROJECT_NAME_PASCAL}}/Info.plist"
  "ios/{{PROJECT_NAME_PASCAL}}App/Sources/{{PROJECT_NAME_PASCAL}}App/App/{{PROJECT_NAME_PASCAL}}RootView.swift"
)

for path in "${must_not_be_ignored[@]}"; do
  if git check-ignore -q "$path"; then
    echo "Expected path to remain tracked (not ignored): $path" >&2
    exit 1
  fi
done

if grep -Eq '^ios/\*\*$' "$GITIGNORE"; then
  echo "Detected over-broad ignore pattern: ios/**" >&2
  exit 1
fi

echo "gitignore iOS artifact behavior test passed."
