//
//  DayKey.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import Foundation

enum DayKey {
    static func todayUTC() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
