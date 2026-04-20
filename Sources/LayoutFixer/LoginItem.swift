import ServiceManagement

enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func enable() {
        do { try SMAppService.mainApp.register() }
        catch { NSLog("LoginItem enable failed: \(error)") }
    }

    static func disable() {
        do { try SMAppService.mainApp.unregister() }
        catch { NSLog("LoginItem disable failed: \(error)") }
    }

    static func toggle() {
        isEnabled ? disable() : enable()
    }

    // Enable once on first launch so the user doesn't have to opt in.
    // Subsequent launches respect whatever the user set via the menu.
    static func enableOnFirstLaunch() {
        let key = "LayoutFixer.loginItemSeeded"
        let ud = UserDefaults.standard
        guard !ud.bool(forKey: key) else { return }
        enable()
        ud.set(true, forKey: key)
    }
}
