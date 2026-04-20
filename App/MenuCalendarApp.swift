import MenuCalendarUI
import SwiftUI

@main
struct MenuCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = MenuCalendarState()

    var body: some Scene {
        MenuBarExtra {
            CalendarMenuContent(
                selectedDate: $state.selectedDate,
                calendar: state.calendarForDisplay,
                launchAtLoginEnabled: state.launchAtLoginEnabled,
                onLaunchAtLoginChanged: state.setLaunchAtLoginEnabled
            )
        } label: {
            Text(state.menuBarTitle)
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}
