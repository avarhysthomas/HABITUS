//
//  DashboardViewModel.swift
//  HABITUS
//
//  Created by Ava Thomas on 14/01/2026.
//


import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var todayStrain: Double = 0.0
    @Published var recoveryText: String = "--"
    @Published var recoverySubtitle: String = "Add sleep soon"
    @Published var strainSubtitle: String = "Log an activity to begin"

    // Temporary: pretend we loaded data
    func load() {
        // Later: fetch from Firestore / computed metrics
        updateDerivedText()
    }

    func setStrain(_ value: Double) {
        todayStrain = value
        updateDerivedText()
    }

    private func updateDerivedText() {
        if todayStrain <= 0 {
            strainSubtitle = "Log an activity to begin"
        } else if todayStrain < 50 {
            strainSubtitle = "Light day so far"
        } else if todayStrain < 120 {
            strainSubtitle = "Moderate load today"
        } else {
            strainSubtitle = "High load — prioritise recovery"
        }
    }
}
