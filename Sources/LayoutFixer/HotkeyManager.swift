import Carbon.HIToolbox
import Foundation

// Top-level C-compatible callback — cannot be a closure with captures.
// Routes the event to the singleton's stored action.
private func hotkeyEventHandler(
    _: EventHandlerCallRef?,
    _: EventRef?,
    _: UnsafeMutableRawPointer?
) -> OSStatus {
    HotkeyManager.shared.fire()
    return noErr
}

final class HotkeyManager {
    static let shared = HotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var action: (() -> Void)?

    private init() {
        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            hotkeyEventHandler,
            1,
            &spec,
            nil,
            nil
        )
    }

    /// Register a single global hotkey.
    /// - Parameters:
    ///   - keyCode: Carbon virtual key code (e.g. kVK_ANSI_A = 0x00)
    ///   - modifiers: Carbon modifier mask (e.g. cmdKey | shiftKey)
    func register(keyCode: Int, modifiers: Int, action: @escaping () -> Void) {
        self.action = action

        var id = EventHotKeyID()
        id.signature = 0x4C465800 // 'LFX\0'
        id.id = 1

        RegisterEventHotKey(
            UInt32(keyCode),
            UInt32(modifiers),
            id,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func fire() {
        action?()
    }

    deinit {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref) }
    }
}
