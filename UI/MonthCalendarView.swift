import MenuCalendarCore
import SwiftUI

public struct MonthCalendarView: View {
    @Binding private var selectedDate: Date
    private let calendar: Calendar

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
            HStack(spacing: 8) {
                Button {
                    if let moved = CalendarMonthNavigator.monthOffset(from: selectedDate, by: -1, calendar: calendar) {
                        selectedDate = moved
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                Text(monthTitle)
                    .font(.headline)
                    .monospacedDigit()

                Spacer(minLength: 0)

                Button {
                    if let moved = CalendarMonthNavigator.monthOffset(from: selectedDate, by: 1, calendar: calendar) {
                        selectedDate = moved
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            HStack(spacing: 0) {
                ForEach(weekdaySymbolsInOrder.indices, id: \.self) { idx in
                    Text(weekdaySymbolsInOrder[idx])
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                spacing: 1
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
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.accentColor)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }

                            Text("\(day)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(isSelected ? .white : (inMonth ? .primary : .secondary))
                                .frame(maxWidth: .infinity, minHeight: 22)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
