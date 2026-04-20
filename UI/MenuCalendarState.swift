import Combine
import Foundation
import MenuCalendarCore

@MainActor
public final class MenuCalendarState: ObservableObject {
    public let clock: ClockModel
    @Published public var selectedDate: Date
    @Published public private(set) var launchAtLoginEnabled: Bool
    @Published public private(set) var launchAtLoginErrorMessage: String?

    private let launchAtLoginController: any LaunchAtLoginControlling
    private var lastNow: Date
    private var cancellables: Set<AnyCancellable> = []

    /// Menu bar and calendar follow the **macOS system time zone** (updates when the user changes it).
    public var displayTimeZone: TimeZone { TimeZone.autoupdatingCurrent }

    public init(
        clock: ClockModel? = nil,
        launchAtLoginController: any LaunchAtLoginControlling = LaunchAtLoginController()
    ) {
        let initialClock = clock ?? ClockModel(now: Date(), runsTimer: true)
        self.launchAtLoginController = launchAtLoginController
        self.clock = initialClock
        self.selectedDate = initialClock.now
        self.launchAtLoginEnabled = launchAtLoginController.isEnabled
        self.lastNow = initialClock.now

        initialClock.$now
            .sink { [weak self] newNow in
                self?.applyClockTick(newNow)
            }
            .store(in: &cancellables)
    }

    public var calendarForDisplay: Calendar {
        MenuCalendarCalendarFactory.displayCalendar(timeZone: displayTimeZone)
    }

    public var menuBarTitle: String {
        MenuBarDateFormatter.makeTitle(from: clock.now, timeZone: displayTimeZone)
    }

    public func setLaunchAtLoginEnabled(_ enabled: Bool) {
        let previous = launchAtLoginEnabled
        do {
            try launchAtLoginController.setEnabled(enabled)
            launchAtLoginEnabled = launchAtLoginController.isEnabled
            launchAtLoginErrorMessage = nil
        } catch {
            launchAtLoginEnabled = previous
            launchAtLoginErrorMessage = error.localizedDescription
        }
    }

    private func applyClockTick(_ newNow: Date) {
        let calendar = calendarForDisplay
        if !calendar.isDate(newNow, inSameDayAs: lastNow) {
            if calendar.isDate(selectedDate, inSameDayAs: lastNow) {
                selectedDate = newNow
            }
        }
        lastNow = newNow
    }
}
