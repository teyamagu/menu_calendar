import Foundation

/// Display `Calendar`: copies `firstWeekday` and other settings from `Calendar.current`, only replacing `timeZone`.
public enum MenuCalendarCalendarFactory {
    public static func displayCalendar(timeZone: TimeZone) -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar
    }
}
