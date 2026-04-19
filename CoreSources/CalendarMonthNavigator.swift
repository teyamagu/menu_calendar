import Foundation

public enum CalendarMonthNavigator {
    public static func monthOffset(from date: Date, by offset: Int, calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: .month, value: offset, to: date)
    }
}
