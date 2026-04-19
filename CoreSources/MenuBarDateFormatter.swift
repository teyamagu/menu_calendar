import Foundation

public enum MenuBarDateFormatter {
    /// ICU pattern for the menu bar title (`EEE` = short weekday).
    public static let titleFormatPattern = "EEE yyyy/MM/dd HH:mm"

    public static func makeTitle(
        from date: Date,
        locale: Locale = .current,
        timeZone: TimeZone = .current
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = titleFormatPattern
        return formatter.string(from: date)
    }
}
