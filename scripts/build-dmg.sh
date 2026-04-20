#!/bin/bash
# Builds Layout Fixer into a distributable .dmg (drag-to-Applications installer).
# Output: dist/LayoutFixer-<version>.dmg
set -euo pipefail

VERSION="${VERSION:-1.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
DIST="$ROOT/dist"
APP="$BUILD/LayoutFixer.app"
DMG="$DIST/LayoutFixer-$VERSION.dmg"

rm -rf "$BUILD" "$DMG"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$DIST"

# --- Info.plist ---------------------------------------------------------------
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>LayoutFixer</string>
    <key>CFBundleDisplayName</key><string>Layout Fixer</string>
    <key>CFBundleIdentifier</key><string>com.tamerlan.layoutfixer</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleExecutable</key><string>LayoutFixer</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSPrincipalClass</key><string>NSApplication</string>
    <key>LSUIElement</key><true/>
    <key>NSAccessibilityUsageDescription</key>
    <string>Layout Fixer needs Accessibility access to copy and paste text when converting keyboard layouts.</string>
</dict>
</plist>
PLIST

# --- Compile ------------------------------------------------------------------
echo "==> Compiling LayoutFixer..."
SDK="$(xcrun --show-sdk-path --sdk macosx)"
swiftc \
    -sdk "$SDK" \
    -target arm64-apple-macosx13.0 \
    -framework AppKit \
    -framework Carbon \
    -framework ServiceManagement \
    -O \
    "$ROOT"/Sources/LayoutFixer/Converter.swift \
    "$ROOT"/Sources/LayoutFixer/HotkeyManager.swift \
    "$ROOT"/Sources/LayoutFixer/TextProcessor.swift \
    "$ROOT"/Sources/LayoutFixer/LoginItem.swift \
    "$ROOT"/Sources/LayoutFixer/StatusBarController.swift \
    "$ROOT"/Sources/LayoutFixer/AppDelegate.swift \
    "$ROOT"/Sources/LayoutFixer/main.swift \
    -o "$APP/Contents/MacOS/LayoutFixer"

# --- Ad-hoc sign --------------------------------------------------------------
# Not notarized — first launch requires right-click → Open on Gatekeeper.
echo "==> Signing (ad-hoc)..."
xattr -cr "$APP"
codesign --force --deep --sign - "$APP"

# --- DMG ----------------------------------------------------------------------
echo "==> Packaging DMG..."
STAGE="$(mktemp -d)"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

hdiutil create \
    -volname "Layout Fixer" \
    -srcfolder "$STAGE" \
    -ov -format UDZO \
    "$DMG" >/dev/null

rm -rf "$STAGE"

echo ""
echo "Done → $DMG"
echo "Size: $(du -h "$DMG" | cut -f1)"
