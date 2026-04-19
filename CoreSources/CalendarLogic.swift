import Foundation

public enum MenuBarDateFormatter {
    public static func makeTitle(
        from date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEE yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

public enum CalendarMonthNavigator {
    public static func monthOffset(from date: Date, by offset: Int, calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: .month, value: offset, to: date)
    }
}

/// Display `Calendar`: copies `firstWeekday` and other settings from `Calendar.current`, only replacing `timeZone`.
public enum MenuCalendarCalendarFactory {
    public static func displayCalendar(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar
    }
}

public enum CalendarMenuLayoutRules {
    public static let popupWidth: Double = 220

    public static let popupPaddingHorizontal: Double = 12
    public static let popupPaddingVertical: Double = 6
    public static let vStackSpacing: Double = 4
}

public enum MenuCalendarControlRules {
    public static let todayButtonTitle = "Today"
    public static let quitMenuTitle = "Quit"
    public static let quitShortcutKey: Character = "q"
}

/// `UserDefaults` key for legacy data removed on launch (reference only).
public enum MenuCalendarLegacyDefaults {
    public static let timeZoneIdentifierKey = "menuCalendar.timeZoneIdentifier"
}
