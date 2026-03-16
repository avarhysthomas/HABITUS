//
//  Goal.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import Foundation

enum GoalType: String, CaseIterable, Codable, Identifiable, Equatable {
    case workoutCount
    case runDistance
    case mobilitySessions
    case meditationSessions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .workoutCount:
            return "Workout Count"
        case .runDistance:
            return "Run Distance"
        case .mobilitySessions:
            return "Mobility Sessions"
        case .meditationSessions:
            return "Meditation Sessions"
        }
    }

    var unit: String {
        switch self {
        case .runDistance:
            return "km"
        default:
            return "sessions"
        }
    }
}

struct Goal: Identifiable, Codable, Equatable {
    let id: String
    let type: GoalType
    var targetValue: Double
    var currentValue: Double
    var isActive: Bool
    var weekStart: String?

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    var remainingValue: Double {
        max(targetValue - currentValue, 0)
    }
}
