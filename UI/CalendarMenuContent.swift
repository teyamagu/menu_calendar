import AppKit
import MenuCalendarCore
import SwiftUI

public struct CalendarMenuContent: View {
    @Binding private var selectedDate: Date
    private let calendar: Calendar
    private let launchAtLoginEnabled: Bool
    private let onLaunchAtLoginChanged: (Bool) -> Void
    private let onQuit: () -> Void

    public init(
        selectedDate: Binding<Date>,
        calendar: Calendar,
        launchAtLoginEnabled: Bool = false,
        onLaunchAtLoginChanged: @escaping (Bool) -> Void = { _ in },
        onQuit: @escaping () -> Void = { NSApplication.shared.terminate(nil) }
    ) {
        self._selectedDate = selectedDate
        self.calendar = calendar
        self.launchAtLoginEnabled = launchAtLoginEnabled
        self.onLaunchAtLoginChanged = onLaunchAtLoginChanged
        self.onQuit = onQuit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CalendarMenuLayoutRules.vStackSpacing) {
            Divider()

            MonthCalendarView(selectedDate: $selectedDate, calendar: calendar)

            Button(MenuCalendarControlRules.todayButtonTitle) {
                selectedDate = Date()
            }
            .keyboardShortcut("t", modifiers: [.command])

            Toggle(
                MenuCalendarControlRules.launchAtLoginToggleTitle,
                isOn: Binding(
                    get: { launchAtLoginEnabled },
                    set: { onLaunchAtLoginChanged($0) }
                )
            )

            Divider()

            Button(MenuCalendarControlRules.quitMenuTitle) {
                onQuit()
            }
            .keyboardShortcut(
                KeyEquivalent(MenuCalendarControlRules.quitShortcutKey),
                modifiers: [.command]
            )
        }
        .padding(.horizontal, CalendarMenuLayoutRules.popupPaddingHorizontal)
        .padding(.vertical, CalendarMenuLayoutRules.popupPaddingVertical)
        .frame(maxWidth: CalendarMenuLayoutRules.popupWidth)
        .fixedSize(horizontal: true, vertical: true)
    }
}
