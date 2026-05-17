# Layout Fixer

Converts text typed in the wrong keyboard layout between **QWERTY** and
**ЙЦУКЕН** (Russian). Select the garbled text, press a hotkey, and the app
pastes it back correctly.

Two builds share the same conversion table:

| Platform | Hotkey       | Language | Framework                 |
|----------|--------------|----------|---------------------------|
| macOS    | `⌘S`         | Swift    | AppKit + Carbon           |
| Windows  | `Ctrl+Shift+S` | AutoHotkey v2 | n/a                |

Both start automatically on login.

---

## macOS install

1. Download `LayoutFixer-<version>.dmg` from the [Releases](../../releases) page.
2. Open the DMG and drag **Layout Fixer** into **Applications**.
3. Open it once (right-click → **Open** the first time, since the build is
   ad-hoc signed, not notarized).
4. Grant **Accessibility** permission when prompted:
   *System Settings → Privacy & Security → Accessibility → enable Layout Fixer.*
5. The app lives in the menu bar as a small **keyboard** icon (SF Symbol,
   auto-adapts to light/dark mode). Press `⌘S` to convert the selection.

"Launch at Login" is enabled on first run and can be toggled from the menu.

### Build from source (macOS)

```bash
git clone https://github.com/RadioTamerlan/layout-fixer.git
cd layout-fixer
bash scripts/build-dmg.sh      # → dist/LayoutFixer-1.0.dmg
```

Requires:

- Xcode Command Line Tools (`xcode-select --install`).
- `librsvg` if you want the Finder/Spotlight app icon embedded
  (`brew install librsvg`). If missing, the build still succeeds but the app
  uses the generic macOS app icon.

The build script (`scripts/build-dmg.sh`) renders `assets/AppIcon.svg` into a
multi-resolution `.icns` at build time and bundles it via `CFBundleIconFile`.

---

## Windows install

1. Download `LayoutFixer-windows.zip` from the [Releases](../../releases) page.
2. Extract it.
3. Double-click **install.bat**. It copies the app to `%LOCALAPPDATA%\LayoutFixer`,
   adds a Startup shortcut, and launches it.
4. The app lives in the system tray. Press `Ctrl+Shift+S` to convert the selection.

### Build from source (Windows)

1. Install [AutoHotkey v2](https://www.autohotkey.com/).
2. Right-click `windows/LayoutFixer.ahk` → **Compile Script**. This produces
   `LayoutFixer.exe`. Ship it alongside `install.bat`.

Alternatively, run `LayoutFixer.ahk` directly without compiling — AutoHotkey
will execute it and add itself to Startup on first run.

---

## How it works

- Captures the global hotkey.
- Simulates Copy → reads the clipboard → runs `Converter.autoConvert` → writes
  the converted text back → simulates Paste.
- Saves the previous clipboard contents and restores them afterwards.
- Detects direction automatically: a majority of Latin characters means the
  user intended Russian (→ EN→RU), majority Cyrillic means they intended
  English (→ RU→EN).
- On macOS, pressing the hotkey with **nothing selected** undoes the most
  recent conversion.

## Punctuation coverage

The converter handles every printable key on the keyboard, not just letters.
The shift-row punctuation differs between US QWERTY and the **macOS "Russian"**
layout (the default Apple ships):

| US Shift | macOS Russian Shift |
|----------|---------------------|
| `@`      | `"`                 |
| `#`      | `№`                 |
| `$`      | `%`                 |
| `%`      | `:`                 |
| `^`      | `,`                 |
| `&`      | `.`                 |
| `*`      | `;`                 |

So `Ghbdtn^ rfr ltkf?` converts to `Привет, как дела?` (the `^` typed on US
QWERTY corresponds to `,` on macOS Russian's Shift+6).

**Caveat — "Russian – PC" layout users:** macOS also ships a *Russian – PC*
layout that mirrors Windows. Its shift row is different (`Shift+6` = `:` there,
not `,`). The current mappings target the default macOS Russian layout. If you
use Russian – PC, the letter keys still convert correctly but the shift-row
punctuation will be off.

## License

MIT — see [LICENSE](LICENSE).
