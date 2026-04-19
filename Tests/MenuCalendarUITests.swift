import MenuCalendarCore
import MenuCalendarUI
import SwiftUI
import ViewInspector
import XCTest

// MARK: - MonthCalendarDisplay (logic extracted from the view)

final class MonthCalendarDisplayTests: XCTestCase {
    private let englishUS = Locale(identifier: "en_US")

    func testDisplayedMonthStart_matchesMonthCalendarModel() {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        let mid = TestCalendars.date(year: 2026, month: 3, day: 15, calendar: cal)
        let fromModel = MonthCalendarModel.monthStart(for: mid, calendar: cal)!
        let fromDisplay = MonthCalendarDisplay.displayedMonthStart(for: mid, calendar: cal)
        XCTAssertEqual(fromDisplay.timeIntervalSince1970, fromModel.timeIntervalSince1970, accuracy: 1)
    }

    func testMonthTitle_englishUS_shortMonthAndYear() {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        let d = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        XCTAssertEqual(MonthCalendarDisplay.monthTitle(for: d, calendar: cal, locale: englishUS), "Mar 2026")
    }

    func testMonthTitle_englishUS_january() {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        let d = TestCalendars.date(year: 2026, month: 1, day: 31, calendar: cal)
        XCTAssertEqual(MonthCalendarDisplay.monthTitle(for: d, calendar: cal, locale: englishUS), "Jan 2026")
    }

    func testMonthTitle_japaneseLocale_matchesReferenceFormatter() {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        let d = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        let ja = Locale(identifier: "ja_JP")
        let start = MonthCalendarDisplay.displayedMonthStart(for: d, calendar: cal)
        let ref = DateFormatter()
        ref.locale = ja
        ref.calendar = cal
        ref.setLocalizedDateFormatFromTemplate(MonthCalendarDisplay.monthHeaderDateTemplate)
        XCTAssertEqual(MonthCalendarDisplay.monthTitle(for: d, calendar: cal, locale: ja), ref.string(from: start))
    }

    func testWeekdaySymbolsInOrder_firstWeekdaySunday_matchesBaseSymbols() {
        var cal = TestCalendars.gregorianUTC
        cal.firstWeekday = 1
        let base = cal.shortStandaloneWeekdaySymbols
        let ordered = MonthCalendarDisplay.weekdaySymbolsInOrder(calendar: cal)
        XCTAssertEqual(ordered, base)
    }

    func testWeekdaySymbolsInOrder_firstWeekdayMonday_isRotationOfBase() {
        var cal = TestCalendars.gregorianUTC
        cal.firstWeekday = 2
        let base = cal.shortStandaloneWeekdaySymbols
        let ordered = MonthCalendarDisplay.weekdaySymbolsInOrder(calendar: cal)
        XCTAssertEqual(ordered.count, 7)
        XCTAssertEqual(Set(ordered), Set(base))
        XCTAssertEqual(ordered[0], base[1])
    }
}

// MARK: - MenuCalendarState + ClockModel

@MainActor
final class MenuCalendarStateBehaviorTests: XCTestCase {
    func testDayAdvance_syncsSelectedDateWhenUserHadBeenOnClockDay() {
        let cal = Calendar.current
        let t1 = cal.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 12, minute: 0))!
        let t2 = cal.date(from: DateComponents(year: 2026, month: 4, day: 11, hour: 12, minute: 0))!

        let clock = ClockModel(now: t1, runsTimer: false)
        let state = MenuCalendarState(clock: clock)
        XCTAssertTrue(cal.isDate(state.selectedDate, inSameDayAs: t1))

        clock.setNowForTesting(t2)
        XCTAssertTrue(cal.isDate(state.selectedDate, inSameDayAs: t2))
    }

    func testDayAdvance_doesNotOverwriteWhenUserSelectedDifferentDay() {
        let cal = Calendar.current
        let t1 = cal.date(from: DateComponents(year: 2026, month: 4, day: 10, hour: 12, minute: 0))!
        let t2 = cal.date(from: DateComponents(year: 2026, month: 4, day: 11, hour: 12, minute: 0))!
        let userPick = cal.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 12, minute: 0))!

        let clock = ClockModel(now: t1, runsTimer: false)
        let state = MenuCalendarState(clock: clock)
        state.selectedDate = userPick

        clock.setNowForTesting(t2)
        XCTAssertTrue(cal.isDate(state.selectedDate, inSameDayAs: userPick))
    }

    func testMenuBarTitle_matchesFormatterWithAutoupdatingSystemTimeZone() {
        let clock = ClockModel(now: Date(timeIntervalSince1970: 1_700_000_000), runsTimer: false)
        let state = MenuCalendarState(clock: clock)
        let expected = MenuBarDateFormatter.makeTitle(from: clock.now, timeZone: TimeZone.autoupdatingCurrent)
        XCTAssertEqual(state.menuBarTitle, expected)
    }

    func testDisplayTimeZone_isAutoupdatingCurrent() {
        let state = MenuCalendarState(clock: ClockModel(runsTimer: false))
        XCTAssertEqual(state.displayTimeZone.identifier, TimeZone.autoupdatingCurrent.identifier)
    }
}

// MARK: - ViewInspector (SwiftUI wiring)

@MainActor
final class MonthCalendarViewInspectorTests: XCTestCase {
    func testShowsMonthTitle() throws {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        let date = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        let expected = MonthCalendarDisplay.monthTitle(for: date, calendar: cal)
        let view = MonthCalendarView(selectedDate: .constant(date), calendar: cal)
        let title = try view.inspect().find(text: expected).string()
        XCTAssertTrue(title.contains("2026"))
    }

    func testPrevMonthButton_movesSelectionBackward() throws {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        var selected = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        let binding = Binding(
            get: { selected },
            set: { selected = $0 }
        )
        let view = MonthCalendarView(selectedDate: binding, calendar: cal)
        let navButtons = try view.inspect().vStack().hStack(0).findAll(ViewType.Button.self)
        XCTAssertEqual(navButtons.count, 2)
        try navButtons[0].tap()
        let (y, m, d) = TestCalendars.ymd(selected, calendar: cal)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 2)
        XCTAssertEqual(d, 26)
    }

    func testNextMonthButton_movesSelectionForward() throws {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        var selected = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        let binding = Binding(
            get: { selected },
            set: { selected = $0 }
        )
        let view = MonthCalendarView(selectedDate: binding, calendar: cal)
        let navButtons = try view.inspect().vStack().hStack(0).findAll(ViewType.Button.self)
        try navButtons[1].tap()
        let (y, m, d) = TestCalendars.ymd(selected, calendar: cal)
        XCTAssertEqual(y, 2026)
        XCTAssertEqual(m, 4)
        XCTAssertEqual(d, 26)
    }

    func testGridDayButton_updatesSelectionToThatDay() throws {
        let cal = TestCalendars.gregorianUTC(firstWeekday: 2)
        var selected = TestCalendars.date(year: 2026, month: 3, day: 26, calendar: cal)
        let binding = Binding(
            get: { selected },
            set: { selected = $0 }
        )
        let expectedCell = MonthCalendarModel.daysGrid(for: selected, calendar: cal)[10]
        let view = MonthCalendarView(selectedDate: binding, calendar: cal)
        let grid = try view.inspect().vStack().lazyVGrid(2)
        try grid.forEach(0).button(10).tap()
        XCTAssertTrue(MonthCalendarModel.isSameDay(selected, expectedCell, calendar: cal))
    }
}

@MainActor
final class CalendarMenuContentInspectorTests: XCTestCase {
    private var testCalendar: Calendar {
        TestCalendars.gregorianUTC(firstWeekday: 2)
    }

    func testQuitButton_invokesInjectedHandler() throws {
        var quitCalled = false
        let date = TestCalendars.date(year: 2026, month: 3, day: 26)
        let view = CalendarMenuContent(
            selectedDate: .constant(date),
            calendar: testCalendar,
            onQuit: { quitCalled = true }
        )
        try view.inspect().find(button: MenuCalendarControlRules.quitMenuTitle).tap()
        XCTAssertTrue(quitCalled)
    }

    func testTodayButton_updatesBindingToSameCalendarDayAsDate() throws {
        var selected = TestCalendars.date(year: 2020, month: 1, day: 1)
        let binding = Binding(
            get: { selected },
            set: { selected = $0 }
        )
        let view = CalendarMenuContent(
            selectedDate: binding,
            calendar: testCalendar,
            onQuit: {}
        )
        try view.inspect().find(button: MenuCalendarControlRules.todayButtonTitle).tap()
        XCTAssertTrue(Calendar.current.isDateInToday(selected))
    }
}
