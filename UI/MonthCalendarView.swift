import MenuCalendarCore
import SwiftUI

public struct MonthCalendarView: View {
    @Binding private var selectedDate: Date
    private let calendar: Calendar

    private enum Metrics {
        static let navHStackSpacing: CGFloat = 8
        static let navChevronFontSize: CGFloat = 12
        static let navChevronWeight: Font.Weight = .semibold
        static let navButtonFrame: CGFloat = 20
        static let headerBottomPadding: CGFloat = 4
        static let weekdayRowBottomPadding: CGFloat = 4
        static let gridSpacing: CGFloat = 1
        static let dayCellFontSize: CGFloat = 14
        static let dayCellFontWeight: Font.Weight = .medium
        static let dayCellMinHeight: CGFloat = 22
        static let selectionCornerRadius: CGFloat = 6
    }

    public init(selectedDate: Binding<Date>, calendar: Calendar = .current) {
        self._selectedDate = selectedDate
        self.calendar = calendar
    }

    private var monthTitle: String {
        MonthCalendarDisplay.monthTitle(for: selectedDate, calendar: calendar)
    }

    private var weekdaySymbolsInOrder: [String] {
        MonthCalendarDisplay.weekdaySymbolsInOrder(calendar: calendar)
    }

    private var daysGrid: [Date] {
        MonthCalendarModel.daysGrid(for: selectedDate, calendar: calendar)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Metrics.navHStackSpacing) {
                monthNavigationButton(systemName: "chevron.left", monthDelta: -1)

                Spacer(minLength: 0)

                Text(monthTitle)
                    .font(.headline)
                    .monospacedDigit()

                Spacer(minLength: 0)

                monthNavigationButton(systemName: "chevron.right", monthDelta: 1)
            }
            .padding(.bottom, Metrics.headerBottomPadding)

            HStack(spacing: 0) {
                ForEach(weekdaySymbolsInOrder.indices, id: \.self) { idx in
                    Text(weekdaySymbolsInOrder[idx])
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, Metrics.weekdayRowBottomPadding)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: Metrics.gridSpacing
            ) {
                ForEach(daysGrid, id: \.timeIntervalSince1970) { date in
                    let day = calendar.component(.day, from: date)
                    let inMonth = MonthCalendarModel.isSameMonth(date, selectedDate, calendar: calendar)
                    let isSelected = MonthCalendarModel.isSameDay(date, selectedDate, calendar: calendar)

                    Button {
                        selectedDate = date
                    } label: {
                        ZStack {
                            if isSelected {
                                RoundedRectangle(cornerRadius: Metrics.selectionCornerRadius)
                                    .fill(Color.accentColor)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }

                            Text("\(day)")
                                .font(.system(size: Metrics.dayCellFontSize, weight: Metrics.dayCellFontWeight))
                                .foregroundStyle(isSelected ? .white : (inMonth ? .primary : .secondary))
                                .frame(maxWidth: .infinity, minHeight: Metrics.dayCellMinHeight)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func monthNavigationButton(systemName: String, monthDelta: Int) -> some View {
        Button {
            if let moved = CalendarMonthNavigator.monthOffset(
                from: selectedDate,
                by: monthDelta,
                calendar: calendar
            ) {
                selectedDate = moved
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: Metrics.navChevronFontSize, weight: Metrics.navChevronWeight))
                .frame(width: Metrics.navButtonFrame, height: Metrics.navButtonFrame)
        }
        .buttonStyle(.plain)
    }
}
