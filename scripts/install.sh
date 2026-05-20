#!/usr/bin/env bash
# VoiceInk fork installer — downloads the latest release, removes quarantine,
# installs to /Applications, and launches.
#
# Usage:  curl -sL https://github.com/Vnedrenec/VoiceInk/releases/latest/download/install.sh | bash
set -euo pipefail

REPO="Vnedrenec/VoiceInk"
APP_NAME="VoiceInk.app"
APP_PATH="/Applications/${APP_NAME}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

say() { printf "\n\033[1;34m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m[x]\033[0m %s\n" "$*" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || die "macOS only."
[[ "$(uname -m)" == "arm64" ]] || warn "This build targets Apple Silicon (arm64). Intel Macs may not run it."

say "Fetching latest release info from $REPO"
ASSET_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep -oE '"browser_download_url": *"[^"]*VoiceInk-[^"]*\.zip"' \
  | head -1 \
  | sed -E 's/.*"(https[^"]+)".*/\1/')

[[ -n "$ASSET_URL" ]] || die "Could not find a .zip asset in the latest release."

say "Downloading $(basename "$ASSET_URL")"
curl -fL -o "$TMP_DIR/voiceink.zip" "$ASSET_URL"

say "Extracting"
unzip -q "$TMP_DIR/voiceink.zip" -d "$TMP_DIR"

[[ -d "$TMP_DIR/${APP_NAME}" ]] || die "Archive did not contain ${APP_NAME}"

if pgrep -f "${APP_PATH}" >/dev/null 2>&1; then
  say "Stopping running VoiceInk"
  pkill -f "${APP_PATH}" || true
  sleep 1
fi

if [[ -d "$APP_PATH" ]]; then
  say "Removing existing /Applications/${APP_NAME}"
  rm -rf "$APP_PATH"
fi

say "Installing to /Applications"
ditto "$TMP_DIR/${APP_NAME}" "$APP_PATH"

say "Removing quarantine attribute (Gatekeeper bypass)"
xattr -cr "$APP_PATH"

say "Launching VoiceInk"
open "$APP_PATH"

cat <<EOF

VoiceInk installed and launched.

Next step — grant three permissions in System Settings -> Privacy & Security:
  1. Microphone        (record audio)
  2. Accessibility     (paste into cursor)
  3. Input Monitoring  (capture global shortcut)

Updates: use VoiceInk menu -> "Check for Updates..." for future releases.
EOF
