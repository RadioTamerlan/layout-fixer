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

# --- App icon -----------------------------------------------------------------
# Render assets/AppIcon.svg into an Apple .icns at every required size.
# rsvg-convert is required: `brew install librsvg` if missing.
if [[ -f "$ROOT/assets/AppIcon.svg" ]]; then
    if ! command -v rsvg-convert >/dev/null 2>&1; then
        echo "==> Skipping app icon: install librsvg with 'brew install librsvg' to embed one."
    else
        echo "==> Generating app icon (.icns)..."
        ICONSET="$BUILD/AppIcon.iconset"
        mkdir -p "$ICONSET"
        # Apple iconset requires these exact filenames + sizes
        for entry in \
            "16:icon_16x16.png" "32:icon_16x16@2x.png" \
            "32:icon_32x32.png" "64:icon_32x32@2x.png" \
            "128:icon_128x128.png" "256:icon_128x128@2x.png" \
            "256:icon_256x256.png" "512:icon_256x256@2x.png" \
            "512:icon_512x512.png" "1024:icon_512x512@2x.png"; do
            size="${entry%%:*}"
            name="${entry##*:}"
            rsvg-convert -w "$size" -h "$size" "$ROOT/assets/AppIcon.svg" -o "$ICONSET/$name"
        done
        iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
    fi
fi

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
    <key>CFBundleIconFile</key><string>AppIcon.icns</string>
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
