import Foundation

/// Gregorian calendar in UTC for reproducible tests.
enum TestCalendars {
    static var gregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    static func gregorianUTC(firstWeekday: Int) -> Calendar {
        var calendar = gregorianUTC
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        calendar: Calendar = TestCalendars.gregorianUTC
    ) -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        guard let date = components.date else {
            preconditionFailure("invalid date: \(year)-\(month)-\(day) \(hour):\(minute)")
        }
        return date
    }

    static func ymd(_ date: Date, calendar: Calendar = TestCalendars.gregorianUTC) -> (Int, Int, Int) {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return (c.year!, c.month!, c.day!)
    }
}
