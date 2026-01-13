//
//  MetricsStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 14/01/2026.
//


import Foundation

@MainActor
final class MetricsStore: ObservableObject {

    // Core metrics (later: loaded from Firestore)
    @Published var todayStrain: Double = 0.0
    @Published var recoveryText: String = "--"

    // Simple placeholder “engine”
    func logActivity(type: String, durationMinutes: Double, intensity: Double) {
        let weight = activityWeight(for: type)

        // v0 strain model (simple + defensible for now)
        let added = intensity * durationMinutes * weight

        todayStrain = round((todayStrain + added) * 10) / 10
    }

    // MARK: - Derived UI text

    var strainSubtitle: String {
        if todayStrain <= 0 { return "Log an activity to begin" }
        if todayStrain < 50 { return "Light day so far" }
        if todayStrain < 120 { return "Moderate load today" }
        return "High load — prioritise recovery"
    }

    var recoverySubtitle: String {
        "Add sleep soon"
    }

    // MARK: - Helpers

    private func activityWeight(for type: String) -> Double {
        switch type {
        case "Walk": return 0.4
        case "Mobility", "Yoga": return 0.6
        case "Run": return 1.2
        case "Hyrox": return 1.4
        case "Strength": return 1.0
        default: return 1.0
        }
    }
}
