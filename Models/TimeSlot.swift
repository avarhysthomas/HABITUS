//
//  TimeSlot.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation

struct TimeSlot: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    
    var durationMinutes: Int {
        Int(end.timeIntervalSince(start) / 60)
    }
}