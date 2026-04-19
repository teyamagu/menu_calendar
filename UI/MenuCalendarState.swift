import Combine
import Foundation
import MenuCalendarCore

@MainActor
public final class MenuCalendarState: ObservableObject {
    public let clock: ClockModel
    @Published public var selectedDate: Date

    private var lastNow: Date
    private var cancellables: Set<AnyCancellable> = []

    /// Menu bar and calendar follow the **macOS system time zone** (updates when the user changes it).
    public var displayTimeZone: TimeZone { TimeZone.autoupdatingCurrent }

    public init(clock: ClockModel? = nil) {
        let initialClock = clock ?? ClockModel(now: Date(), runsTimer: true)
        self.clock = initialClock
        self.selectedDate = initialClock.now
        self.lastNow = initialClock.now

        initialClock.$now
            .sink { [weak self] newNow in
                guard let self else { return }

                let calendar = self.calendarForDisplay
                if !calendar.isDate(newNow, inSameDayAs: self.lastNow) {
                    if calendar.isDate(self.selectedDate, inSameDayAs: self.lastNow) {
                        self.selectedDate = newNow
                    }
                }
                self.lastNow = newNow
            }
            .store(in: &cancellables)
    }

    public var calendarForDisplay: Calendar {
        MenuCalendarCalendarFactory.displayCalendar(timeZone: displayTimeZone)
    }

    public var menuBarTitle: String {
        MenuBarDateFormatter.makeTitle(from: clock.now, timeZone: displayTimeZone)
    }
}
