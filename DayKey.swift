//
//  DayKey.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//
import Foundation

func todayKeyUTC() -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}
