import Combine
import Foundation

public final class ClockModel: ObservableObject {
    @Published public private(set) var now: Date

    private var timer: Timer?
    private let runsTimer: Bool

    /// - Parameters:
    ///   - now: Initial “now” instant.
    ///   - runsTimer: When `false`, does not start the per-minute boundary timer (for unit tests).
    public init(now: Date = Date(), runsTimer: Bool = true) {
        self.now = now
        self.runsTimer = runsTimer
        if runsTimer {
            startTimer()
        }
    }

    deinit {
        timer?.invalidate()
    }

    /// Advances the clock for tests and previews.
    public func setNowForTesting(_ date: Date) {
        now = date
    }

    private func startTimer() {
        scheduleTimerToNextMinuteBoundary()
    }

    private func scheduleTimerToNextMinuteBoundary() {
        timer?.invalidate()

        let calendar = Calendar.current
        let current = Date()

        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: current)
        comps.second = 0
        let startOfCurrentMinute = calendar.date(from: comps) ?? current
        let nextMinute = calendar.date(byAdding: .minute, value: 1, to: startOfCurrentMinute)
            ?? current.addingTimeInterval(60)

        let interval = max(0.1, nextMinute.timeIntervalSinceNow)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.now = Date()
            self.scheduleTimerToNextMinuteBoundary()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
}
