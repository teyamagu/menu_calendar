import Foundation
import MenuCalendarCore

/// Display helpers for `MonthCalendarView` (unit-testable without SwiftUI).
public enum MonthCalendarDisplay {
    public static func displayedMonthStart(for selectedDate: Date, calendar: Calendar) -> Date {
        MonthCalendarModel.monthStart(for: selectedDate, calendar: calendar) ?? selectedDate
    }

    public static func monthTitle(for selectedDate: Date, calendar: Calendar, locale: Locale = .current) -> String {
        let start = displayedMonthStart(for: selectedDate, calendar: calendar)
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMMM")
        return formatter.string(from: start)
    }

    public static func weekdaySymbolsInOrder(calendar: Calendar) -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstIndex = (calendar.firstWeekday - 1) % 7
        return (0 ..< 7).map { symbols[(firstIndex + $0) % 7] }
    }
}
