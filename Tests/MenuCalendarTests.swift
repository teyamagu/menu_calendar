import MenuCalendarCore
import XCTest

// MARK: - MenuBarDateFormatter

final class MenuBarDateFormatterTests: XCTestCase {
    /// Pins `ja_JP` output against Foundation’s formatter (no Japanese literals in source).
    func testMakeTitle_japaneseLocale_matchesReferenceFormatter() {
        let date = TestCalendars.date(year: 2026, month: 3, day: 26, hour: 17, minute: 9)
        let tz = TestCalendars.gregorianUTC.timeZone
        let ja = Locale(identifier: "ja_JP")
        let ref = DateFormatter()
        ref.locale = ja
        ref.timeZone = tz
        ref.dateFormat = "EEE yyyy/MM/dd HH:mm"
        let expected = ref.string(from: date)
        let text = MenuBarDateFormatter.makeTitle(from: date, locale: ja, timeZone: tz)
        XCTAssertEqual(text, expected)
    }

    /// `en_US_POSIX` keeps weekday labels stable across environments.
    func testMakeTitle_enUSPOSIX_formatsConsistently() {
        let date = TestCalendars.date(year: 2026, month: 3, day: 26, hour: 17, minute: 9)
        let tz = TestCalendars.gregorianUTC.timeZone
        let text = MenuBarDateFormatter.makeTitle(
            from: date,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: tz
        )
        XCTAssertEqual(text, "Thu 2026/03/26 17:09")
    }

    /// `timeZone` affects the calendar day shown (same instant can be a different local date).
    func testMakeTitle_respectsTimeZone_crossingCalendarDate() {
        let date = TestCalendars.date(year: 2026, month: 3, day: 26, hour: 15, minute: 0)
        let tokyo = TimeZone(identifier: "Asia/Tokyo")!
        let en = Locale(identifier: "en_US")
        let ref = DateFormatter()
        ref.locale = en
        ref.timeZone = tokyo
        ref.dateFormat = "EEE yyyy/MM/dd HH:mm"
        let expected = ref.string(from: date)
        let text = MenuBarDateFormatter.makeTitle(from: date, locale: en, timeZone: tokyo)
        XCTAssertEqual(text, expected)
    }
}

// MARK: - CalendarMonthNavigator

final class CalendarMonthNavigatorTests: XCTestCase {
    private struct Case {
        let baseY: Int
        let baseM: Int
        let baseD: Int
        let offset: Int
        let expectY: Int
        let expectM: Int
        let expectD: Int
    }

    /// Representative month arithmetic (end-of-month, leap year, year wrap, multi-month).
    func testMonthOffset_expectedYearMonthDay() {
        let calendar = TestCalendars.gregorianUTC
        let cases: [Case] = [
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: 0, expectY: 2026, expectM: 3, expectD: 26),
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: 1, expectY: 2026, expectM: 4, expectD: 26),
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: -1, expectY: 2026, expectM: 2, expectD: 26),
            Case(baseY: 2026, baseM: 1, baseD: 15, offset: 1, expectY: 2026, expectM: 2, expectD: 15),
            Case(baseY: 2026, baseM: 1, baseD: 15, offset: -1, expectY: 2025, expectM: 12, expectD: 15),
            Case(baseY: 2026, baseM: 1, baseD: 31, offset: 1, expectY: 2026, expectM: 2, expectD: 28),
            Case(baseY: 2024, baseM: 1, baseD: 31, offset: 1, expectY: 2024, expectM: 2, expectD: 29),
            Case(baseY: 2024, baseM: 3, baseD: 31, offset: -1, expectY: 2024, expectM: 2, expectD: 29),
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: 12, expectY: 2027, expectM: 3, expectD: 26),
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: -12, expectY: 2025, expectM: 3, expectD: 26),
            Case(baseY: 2026, baseM: 3, baseD: 26, offset: 3, expectY: 2026, expectM: 6, expectD: 26),
        ]

        for item in cases {
            let base = TestCalendars.date(
                year: item.baseY,
                month: item.baseM,
                day: item.baseD,
                calendar: calendar
            )
            guard let moved = CalendarMonthNavigator.monthOffset(from: base, by: item.offset, calendar: calendar) else {
                XCTFail("monthOffset returned nil for base \(item.baseY)-\(item.baseM)-\(item.baseD) offset \(item.offset)")
                continue
            }
            let (y, m, d) = TestCalendars.ymd(moved, calendar: calendar)
            let ctx = "base \(item.baseY)-\(item.baseM)-\(item.baseD) offset \(item.offset)"
            XCTAssertEqual(y, item.expectY, "Y mismatch \(ctx)")
            XCTAssertEqual(m, item.expectM, "M mismatch \(ctx)")
            XCTAssertEqual(d, item.expectD, "D mismatch \(ctx)")
        }
    }
}

// MARK: - MonthCalendarModel

final class MonthCalendarModelTests: XCTestCase {
    func testMonthStart_truncatesToFirstDayOfMonth() {
        let calendar = TestCalendars.gregorianUTC
        let midMonth = TestCalendars.date(year: 2026, month: 3, day: 15, calendar: calendar)
        guard let start = MonthCalendarModel.monthStart(for: midMonth, calendar: calendar) else {
            return XCTFail("monthStart returned nil")
        }
        let (y, m, d) = TestCalendars.ymd(start, calendar: calendar)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 3)
        XCTAssertEqual(d, 1)
        let hour = calendar.component(.hour, from: start)
        XCTAssertEqual(hour, 0)
    }

    func testDaysGrid_has42Cells_andConsecutiveDays() {
        let calendar = TestCalendars.gregorianUTC(firstWeekday: 2)
        let anchor = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: calendar)
        let grid = MonthCalendarModel.daysGrid(for: anchor, calendar: calendar)
        XCTAssertEqual(grid.count, 42)
        for idx in grid.indices.dropFirst() {
            let prev = grid[idx - 1]
            let cur = grid[idx]
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: prev) else {
                XCTFail("date(byAdding:) failed")
                return
            }
            XCTAssertTrue(
                MonthCalendarModel.isSameDay(nextDay, cur, calendar: calendar),
                "grid must be consecutive days at index \(idx)"
            )
        }
    }

    func testDaysGrid_firstCellAlignsToFirstWeekday_mondayWeekStart() {
        let calendar = TestCalendars.gregorianUTC(firstWeekday: 2)
        let anchor = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: calendar)
        let grid = MonthCalendarModel.daysGrid(for: anchor, calendar: calendar)
        guard let first = grid.first else {
            return XCTFail("empty grid")
        }
        XCTAssertEqual(calendar.component(.weekday, from: first), calendar.firstWeekday)

        guard let monthStart = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)) else {
            return XCTFail("month start")
        }
        var expectedStart = monthStart
        while calendar.component(.weekday, from: expectedStart) != calendar.firstWeekday {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: expectedStart) else {
                return XCTFail("walk back weekday")
            }
            expectedStart = prev
        }
        XCTAssertTrue(MonthCalendarModel.isSameDay(first, expectedStart, calendar: calendar))

        guard let last = grid.last,
              let expectedLast = calendar.date(byAdding: .day, value: 41, to: expectedStart)
        else {
            return XCTFail("last cell")
        }
        XCTAssertTrue(MonthCalendarModel.isSameDay(last, expectedLast, calendar: calendar))
    }

    func testDaysGrid_sundayWeekStart_march2026_startsOnSunday() {
        let calendar = TestCalendars.gregorianUTC(firstWeekday: 1)
        let anchor = TestCalendars.date(year: 2026, month: 3, day: 10, calendar: calendar)
        let grid = MonthCalendarModel.daysGrid(for: anchor, calendar: calendar)
        guard let first = grid.first else {
            return XCTFail("empty grid")
        }
        XCTAssertEqual(calendar.component(.weekday, from: first), 1)
        let monthStart = TestCalendars.date(year: 2026, month: 3, day: 1, calendar: calendar)
        XCTAssertTrue(MonthCalendarModel.isSameDay(first, monthStart, calendar: calendar))
    }

    func testDaysGrid_february2025_contains28InMonthDays() {
        let calendar = TestCalendars.gregorianUTC(firstWeekday: 2)
        let anchor = TestCalendars.date(year: 2025, month: 2, day: 15, calendar: calendar)
        let grid = MonthCalendarModel.daysGrid(for: anchor, calendar: calendar)
        XCTAssertEqual(grid.count, 42)
        let inMonth = grid.filter { MonthCalendarModel.isSameMonth($0, anchor, calendar: calendar) }
        XCTAssertEqual(inMonth.count, 28)
    }

    func testIsSameDay_andIsSameMonth() {
        let calendar = TestCalendars.gregorianUTC
        let a = TestCalendars.date(year: 2026, month: 3, day: 26, hour: 3, calendar: calendar)
        let b = TestCalendars.date(year: 2026, month: 3, day: 26, hour: 22, calendar: calendar)
        let c = TestCalendars.date(year: 2026, month: 3, day: 27, calendar: calendar)
        XCTAssertTrue(MonthCalendarModel.isSameDay(a, b, calendar: calendar))
        XCTAssertFalse(MonthCalendarModel.isSameDay(a, c, calendar: calendar))
        XCTAssertTrue(MonthCalendarModel.isSameMonth(a, c, calendar: calendar))
        XCTAssertFalse(
            MonthCalendarModel.isSameMonth(
                a,
                TestCalendars.date(year: 2026, month: 4, day: 1, calendar: calendar),
                calendar: calendar
            )
        )
    }
}

// MARK: - Layout, control rules, factory

final class CalendarMenuLayoutRulesTests: XCTestCase {
    func testLayoutConstants() {
        XCTAssertEqual(CalendarMenuLayoutRules.popupWidth, 220)
        XCTAssertEqual(CalendarMenuLayoutRules.popupPaddingHorizontal, 12)
        XCTAssertEqual(CalendarMenuLayoutRules.popupPaddingVertical, 6)
        XCTAssertEqual(CalendarMenuLayoutRules.vStackSpacing, 4)
    }
}

final class MenuCalendarControlRulesTests: XCTestCase {
    func testQuitMenuStrings() {
        XCTAssertEqual(MenuCalendarControlRules.todayButtonTitle, "Today")
        XCTAssertEqual(MenuCalendarControlRules.quitMenuTitle, "Quit")
        XCTAssertEqual(MenuCalendarControlRules.quitShortcutKey, "q" as Character)
    }
}

// MARK: - MenuCalendarCalendarFactory

final class MenuCalendarCalendarFactoryTests: XCTestCase {
    func testDisplayCalendar_preservesFirstWeekdayFromCurrent() {
        let tz = TimeZone(identifier: "Asia/Tokyo")!
        let built = MenuCalendarCalendarFactory.displayCalendar(timeZone: tz)
        XCTAssertEqual(built.timeZone.identifier, "Asia/Tokyo")
        XCTAssertEqual(built.firstWeekday, Calendar.current.firstWeekday)
    }
}
