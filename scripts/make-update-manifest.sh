#!/usr/bin/env bash
# Build the RegexMate update manifest (rivet format) and merge platform
# artifacts from a release dist directory.
#
# Usage: scripts/make-update-manifest.sh <tag> <dist-dir> <key-der-path>
#
# Emits <dist-dir>/update-manifest.json — the family signed wrapper
# carrying every platform artifact (and the Windows standalone exe) — plus
# SHA256SUMS over all files. Env overrides: RELEASE_ASSET_BASE_URL,
# RIVET_UPDATE_KEY_ID.
#
# The signing, artifact hashing, schema validation, and feed format live in
# `raco rivet sign-manifest`; this wrapper owns only RegexMate's six
# artifacts and identity.
set -euo pipefail

TAG="${1:?usage: make-update-manifest.sh <tag> <dist-dir> <key-der-path>}"
DIST="${2:?usage: make-update-manifest.sh <tag> <dist-dir> <key-der-path>}"
KEY_PATH="${3:?usage: make-update-manifest.sh <tag> <dist-dir> <key-der-path>}"
VERSION="${TAG#v}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$(cd "$DIST" && pwd)"
cd "$ROOT"
KEY_ID="${RIVET_UPDATE_KEY_ID:-regexmate-2026-10}"
BASE_URL="${RELEASE_ASSET_BASE_URL:-https://github.com/turlamai/regexmate/releases/download/$TAG}"

raco rivet check-release-version "$TAG"

BUILD="$(sed -nE 's/.*\(build \. ([0-9]+)\).*/\1/p' "$ROOT/rivet.rktd" | head -n1)"
[[ -n "$BUILD" ]] || {
  echo "error: could not read build from rivet.rktd" >&2
  exit 1
}
[[ -f "$KEY_PATH" ]] || {
  echo "error: missing signing key $KEY_PATH" >&2
  exit 1
}

raco rivet sign-manifest \
  --application-id site.jrtx.regexmate \
  --version "$VERSION" \
  --build "$BUILD" \
  --channel stable \
  --base-url "$BASE_URL" \
  --key-id "$KEY_ID" \
  --private-key "$KEY_PATH" \
  --output "$DIST/update-manifest.json" \
  --artifact "linux:x64:targz:$DIST/regexmate-$VERSION-linux-x86_64.tar.gz" \
  --artifact "linux:arm64:targz:$DIST/regexmate-$VERSION-linux-arm64.tar.gz" \
  --artifact "macos:arm64:targz:$DIST/regexmate-$VERSION-macos-arm64.tar.gz" \
  --artifact "macos:x64:targz:$DIST/regexmate-$VERSION-macos-x64.tar.gz" \
  --artifact "windows:x64:zip:$DIST/regexmate-$VERSION-windows-x86_64.zip" \
  --artifact "windows:x64:exe:$DIST/regexmate-$VERSION-windows-x86_64-standalone.exe" \
  --rollback-allowed

( cd "$DIST" && find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 \
    | sort -z | xargs -0 shasum -a 256 ) > "$DIST/SHA256SUMS"

echo "manifest: $DIST/update-manifest.json (6 artifacts, key-id $KEY_ID)"
echo "checksums: $DIST/SHA256SUMS"
