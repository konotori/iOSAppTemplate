#!/usr/bin/env bash
#
# PreToolUse guard: block agent edits to Xcode project files that corrupt
# easily or must be changed via the Xcode UI. Humans editing in Xcode are
# unaffected — this only fires on the agent's Edit/Write/MultiEdit tools.
#
# Wired in .claude/settings.json for matcher "Edit|Write|MultiEdit".
# Exit 2 blocks the call and feeds stderr back to the agent as the reason.
set -euo pipefail

input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -z "$fp" ] && exit 0

if printf '%s' "$fp" | grep -qE '\.(pbxproj|entitlements|storyboard|xib)$|\.xcodeproj/'; then
  echo "BLOCKED: '$fp' must not be edited by an agent." >&2
  echo "This template uses synchronized folder groups — just create the Swift" >&2
  echo "file in the right folder and Xcode picks it up automatically. For" >&2
  echo "capabilities/signing/entitlements or Interface Builder files, use the" >&2
  echo "Xcode UI." >&2
  exit 2
fi

exit 0
