import AppKit

final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var launchAtLoginItem: NSMenuItem?

    override init() {
        super.init()
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Layout Fixer")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "Layout Fixer — ⌘S to convert selection"
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        let header = NSMenuItem(title: "Layout Fixer", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        menu.addItem(.separator())

        let convertItem = NSMenuItem(
            title: "Convert Selection  ⌘S",
            action: #selector(AppDelegate.convertSelection),
            keyEquivalent: ""
        )
        convertItem.target = NSApp.delegate
        menu.addItem(convertItem)

        menu.addItem(.separator())

        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(AppDelegate.toggleLoginItem),
            keyEquivalent: ""
        )
        loginItem.target = NSApp.delegate
        menu.addItem(loginItem)
        launchAtLoginItem = loginItem

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Layout Fixer",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func menuWillOpen(_: NSMenu) {
        launchAtLoginItem?.state = LoginItem.isEnabled ? .on : .off
    }
}
