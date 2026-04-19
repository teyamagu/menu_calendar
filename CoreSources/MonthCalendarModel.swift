import Foundation

public enum MonthCalendarModel {
    /// Six calendar weeks × 7 columns.
    public static let daysGridCellCount = 42

    public static func monthStart(for date: Date, calendar: Calendar) -> Date? {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps)
    }

    /// One month as a 6-week (42 cell) grid; leading cells align with `calendar.firstWeekday`.
    public static func daysGrid(for date: Date, calendar: Calendar) -> [Date] {
        guard let monthStart = monthStart(for: date, calendar: calendar) else { return [] }

        let firstWeekday = calendar.firstWeekday
        var start = monthStart
        // Walk backward to the first weekday of the grid (simple loop instead of a fragile formula).
        while calendar.component(.weekday, from: start) != firstWeekday {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: start) else { break }
            start = prev
        }

        return (0 ..< daysGridCellCount).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start)
        }
    }

    public static func isSameDay(_ lhs: Date, _ rhs: Date, calendar: Calendar) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    public static func isSameMonth(_ lhs: Date, _ rhs: Date, calendar: Calendar) -> Bool {
        calendar.isDate(lhs, equalTo: rhs, toGranularity: .month)
    }
}
