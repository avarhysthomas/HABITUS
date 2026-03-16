//
//  WeekStripView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct WeekStripView: View {

    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var weekDates: [Date] {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return []
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }

    var body: some View {
        HStack(spacing: 12) {

            ForEach(weekDates, id: \.self) { date in
                DayCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }

        }
        .padding(.horizontal)
    }
}

struct DayCell: View {

    let date: Date
    let isSelected: Bool

    private let calendar = Calendar.current

    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {

        VStack(spacing: 6) {

            Text(dayLetter)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(dayNumber)
                .font(.headline)

        }
        .frame(width: 38, height: 52)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
        )
    }
}
