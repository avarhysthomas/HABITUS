//
//  DayKey.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import Foundation

enum DayKey {
    static func today() -> String {
        from(date: Date())
    }
}

extension DayKey {

    static func from(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    static func currentWeekStart() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let today = Date()

        guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return from(date: today)
        }

        return from(date: interval.start)
    }
}
