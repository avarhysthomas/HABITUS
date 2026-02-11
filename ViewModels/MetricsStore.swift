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
    @Published var todayActivities: [ActivityLog] = []
    @Published var recoveryScore: Int = 0
    @Published var recoveryState: String = "--"
    @Published var recoveryGuidance: String = ""
    @Published var yesterdayStrain: Double = 0.0


    private let recoveryAPI = RecoveryAPI()

    
    init() {
        if let saved = LocalStore.load() {
            self.todayStrain = saved.todayStrain
            self.todayActivities = saved.todayActivities
        }
        refreshRecovery(sleepHours: 7.0, hadRestDay: false)
    }


    // Simple placeholder “engine”
    func logActivity(type: String, durationMinutes: Double, intensity: Double) {
        let weight = activityWeight(for: type)

        let durationInt = Int(durationMinutes.rounded())
        let intensityInt = Int(intensity.rounded())
        
        //v0 Strain
        let added = intensity * durationMinutes * weight
        let addedRounded = round(added*10)/10
        
        //Update Metrics
        todayStrain = round((todayStrain + addedRounded) * 10) / 10

        //Store activity
        let entry = ActivityLog(
            type: type,
            durationMinutes: durationInt,
            intensity: intensityInt,
            strainAdded: addedRounded
        )
        todayActivities.insert(entry, at: 0)
        
        persist()
    }
    
    func refreshRecovery(sleepHours: Double, hadRestDay: Bool) {
        Task {
            do {
                print("Calling recovery with yesterdayStrain=\(yesterdayStrain), sleep=\(sleepHours), rest=\(hadRestDay)")
                
                let res = try await recoveryAPI.computeRecovery(
                    input: RecoveryRequest(
                        yesterdayStrain: yesterdayStrain,
                        sleepHours: sleepHours,
                        hadRestDay: hadRestDay
                    )
                )
                
                print("✅ Recovery response:", res)
                
                await MainActor.run {
                    self.recoveryScore = res.score
                    self.recoveryState = res.state
                    self.recoveryGuidance = res.guidance
                }
            } catch {
                print("RecoveryAPI error:", error)
            }
        }
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
    
    private func persist() {
        LocalStore.save(
            .init(todayStrain: todayStrain, todayActivities: todayActivities)
        )
    }
}
