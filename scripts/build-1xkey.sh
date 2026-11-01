#!/bin/bash
# Build 1xKey.app (menu bar app only, no IMKit input method), optimised for size, and sign it.
# Signing identity: the self-signed "1xKey Code Signing (Pham Xuan Hieu)" certificate in the
# login keychain when present (stable identity: Accessibility/Input Monitoring grants survive
# rebuilds), otherwise ad-hoc. Override with SIGN_ID="...".
# Output: build/release/1xKey.app and 1xKey-<version>.zip (+ .sha256). Requires full Xcode.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "Cần Xcode đầy đủ (xcode-select -s .../Xcode.app/Contents/Developer)."; exit 1
fi

CERT_NAME="1xKey Code Signing (Pham Xuan Hieu)"
if [ -z "${SIGN_ID:-}" ]; then
  if security find-certificate -c "$CERT_NAME" >/dev/null 2>&1; then SIGN_ID="$CERT_NAME"; else SIGN_ID="-"; fi
fi
echo "Ký bằng: $SIGN_ID"

OUT=build/release.noindex
DERIVED=build/derived.noindex
rm -rf "$OUT"; mkdir -p "$OUT"

common=(-project XKey.xcodeproj -configuration Release -derivedDataPath "$DERIVED"
        -destination 'generic/platform=macOS' ARCHS=arm64 ONLY_ACTIVE_ARCH=NO
        CODE_SIGNING_ALLOWED=NO
        SWIFT_OPTIMIZATION_LEVEL=-Osize SWIFT_COMPILATION_MODE=wholemodule
        DEAD_CODE_STRIPPING=YES DEBUG_INFORMATION_FORMAT=dwarf)
xcodebuild "${common[@]}" -scheme XKey build | tail -2

PROD="$DERIVED/Build/Products/Release"
ditto "$PROD/1xKey.app" "$OUT/1xKey.app"

# Drop debug symbols and unused translations (UI is Vietnamese + English only).
strip -x "$OUT/1xKey.app/Contents/MacOS/1xKey"
find "$OUT/1xKey.app" -maxdepth 6 -type d -name 'zh-Hans.lproj' -prune -exec rm -rf {} +

# Sign inside-out with hardened runtime and the minimal entitlements in the repo.
codesign --force --sign "$SIGN_ID" --options=runtime --timestamp=none \
  --entitlements XKey/XKeyRelease.entitlements "$OUT/1xKey.app"
codesign --verify --deep --strict "$PWD/$OUT/1xKey.app"

VER=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$OUT/1xKey.app/Contents/Info.plist")
(cd "$OUT" && ditto -c -k --keepParent 1xKey.app "1xKey-$VER.zip" && shasum -a 256 "1xKey-$VER.zip" | tee "1xKey-$VER.zip.sha256")
du -sh "$OUT/1xKey.app"
echo "Xong: $OUT/1xKey.app"
