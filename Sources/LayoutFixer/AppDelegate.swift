import AppKit
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_: Notification) {
        statusBar = StatusBarController()

        // ⌘S  →  kVK_ANSI_S = 0x01, cmdKey = 0x0100
        HotkeyManager.shared.register(
            keyCode: kVK_ANSI_S,
            modifiers: cmdKey
        ) {
            DispatchQueue.global(qos: .userInitiated).async {
                TextProcessor.convertSelection()
            }
        }

        LoginItem.enableOnFirstLaunch()
        checkAccessibility()
    }

    @objc func toggleLoginItem() {
        LoginItem.toggle()
    }

    @objc func convertSelection() {
        DispatchQueue.global(qos: .userInitiated).async {
            TextProcessor.convertSelection()
        }
    }

    // MARK: - Accessibility

    private func checkAccessibility() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        guard !AXIsProcessTrustedWithOptions(opts as CFDictionary) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAccessibilityAlert()
        }
    }

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Access Required"
        alert.informativeText = """
            Layout Fixer needs Accessibility permission to simulate \
            Copy/Paste when converting text in other apps.

            System Settings → Privacy & Security → Accessibility → enable Layout Fixer.
            """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        if alert.runModal() == .alertFirstButtonReturn {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }
}
