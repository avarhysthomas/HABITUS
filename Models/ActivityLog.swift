//
//  ActivityLog.swift
//  HABITUS
//
//  Created by Ava Thomas on 14/01/2026.
//

import Foundation

struct ActivityLog: Identifiable, Codable, Equatable {
    let id: String
    let type: String
    let durationMinutes: Int
    let intensty: Int
    let strainAdded: Double
    let date: Date
    
    init(
        id: String = UUID().uuidString,
        type: String,
        durationMinutes: Int,
        intensity: Int,
        strainAdded: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.durationMinutes = durationMinutes
        self.intensty = intensity
        self.strainAdded = strainAdded
        self.date = date
    }
    
}
