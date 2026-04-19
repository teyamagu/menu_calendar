import AppKit
import MenuCalendarCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        UserDefaults.standard.removeObject(forKey: MenuCalendarLegacyDefaults.timeZoneIdentifierKey)
        NSApp.setActivationPolicy(.accessory)
    }
}
