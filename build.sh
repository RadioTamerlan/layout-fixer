#!/bin/bash
set -e

APP="$HOME/Desktop/LayoutFixer.app"

echo "Compiling..."
swiftc \
  -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk \
  -target arm64-apple-macosx13.0 \
  -framework AppKit \
  -framework Carbon \
  -framework ServiceManagement \
  -O \
  Sources/LayoutFixer/Converter.swift \
  Sources/LayoutFixer/HotkeyManager.swift \
  Sources/LayoutFixer/TextProcessor.swift \
  Sources/LayoutFixer/LoginItem.swift \
  Sources/LayoutFixer/StatusBarController.swift \
  Sources/LayoutFixer/AppDelegate.swift \
  Sources/LayoutFixer/main.swift \
  -o "$APP/Contents/MacOS/LayoutFixer"

echo "Done → $APP"
echo "Run with: open $APP"
