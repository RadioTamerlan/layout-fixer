import AppKit
import Carbon.HIToolbox

enum TextProcessor {

    // Stores the original text and the length of what was pasted,
    // so we can undo the last conversion without re-selecting.
    private static var lastOriginal: String? = nil
    private static var lastConvertedCount: Int = 0

    static func convertSelection() {
        guard AXIsProcessTrusted() else {
            DispatchQueue.main.async { requestAccessibility() }
            return
        }

        let pb = NSPasteboard.general

        // 1. Snapshot the current clipboard so we can restore it later.
        let snapshot = pb.pasteboardItems?.map { item -> NSPasteboardItem in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            return copy
        }

        // 2. Clear clipboard and copy whatever the user has selected.
        pb.clearContents()
        simulateKey(keyCode: CGKeyCode(kVK_ANSI_C), flags: .maskCommand)
        Thread.sleep(forTimeInterval: 0.12)

        let selected = pb.string(forType: .string)

        // 3. If nothing is selected, try to undo the last conversion.
        if selected == nil || selected!.isEmpty {
            restore(pb, snapshot)
            undoLastConversion()
            return
        }

        // 4. Convert and paste.
        let converted = Converter.autoConvert(selected!)
        guard converted != selected else {
            restore(pb, snapshot)
            return
        }

        pb.clearContents()
        pb.setString(converted, forType: .string)
        simulateKey(keyCode: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
        Thread.sleep(forTimeInterval: 0.12)

        // 5. Remember this conversion so it can be undone.
        lastOriginal = selected
        lastConvertedCount = converted.count

        // 6. Restore original clipboard.
        restore(pb, snapshot)
    }

    // MARK: - Undo

    private static func undoLastConversion() {
        guard let original = lastOriginal, lastConvertedCount > 0 else { return }

        // Re-select the converted text by walking back one character at a time.
        // The cursor is right after the last paste, so Shift+Left × count selects it.
        let src = CGEventSource(stateID: .combinedSessionState)
        for _ in 0..<lastConvertedCount {
            let dn = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_LeftArrow), keyDown: true)
            let up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_LeftArrow), keyDown: false)
            dn?.flags = .maskShift
            up?.flags = .maskShift
            dn?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)
        }
        Thread.sleep(forTimeInterval: 0.15)

        // Paste the original text back.
        let pb = NSPasteboard.general
        let snapshot = pb.pasteboardItems?.map { item -> NSPasteboardItem in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                }
            }
            return copy
        }

        pb.clearContents()
        pb.setString(original, forType: .string)
        simulateKey(keyCode: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
        Thread.sleep(forTimeInterval: 0.12)

        restore(pb, snapshot)

        // Clear undo state — only one level of undo is supported.
        lastOriginal = nil
        lastConvertedCount = 0
    }

    // MARK: - Private

    private static func simulateKey(keyCode: CGKeyCode, flags: CGEventFlags) {
        let src = CGEventSource(stateID: .combinedSessionState)
        let dn = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false)
        dn?.flags = flags
        up?.flags = flags
        dn?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    private static func restore(_ pb: NSPasteboard, _ items: [NSPasteboardItem]?) {
        guard let items, !items.isEmpty else { return }
        pb.clearContents()
        pb.writeObjects(items)
    }

    private static func requestAccessibility() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(opts as CFDictionary)
    }
}
