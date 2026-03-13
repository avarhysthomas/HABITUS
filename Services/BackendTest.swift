//
//  BackendTest.swift
//  HABITUS
//
//  Created by Ava Thomas on 23/02/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFunctions

@MainActor
final class BackendTest {
    private let functions = Functions.functions()

    func runLogSessionTest() async {
        guard Auth.auth().currentUser != nil else {
            print("❌ No authenticated user")
            return
        }

        do {
            let payload: [String: Any] = [
                "dateKey": todayKeyUTC(),
                "durationMinutes": 45,
                "rpe": 7,
                "modality": "HIIT",
                "sleepHours": 6.5,
                "sleepQuality": 3,
                "baselineSleepHours": 7.5
            ]

            let result = try await functions.httpsCallable("logSession").call(payload)
            print("✅ logSession result:", result.data)
        } catch {
            print("❌ logSession failed:", error)
        }
    }

    func runSetDailyInputs(
        sleepHours: Double,
        sleepQuality: Int,
        hadRestDay: Bool
    ) async {
        guard Auth.auth().currentUser != nil else {
            print("❌ No authenticated user")
            return
        }

        do {
            let payload: [String: Any] = [
                "dateKey": todayKeyUTC(),
                "sleepHours": sleepHours,
                "sleepQuality": sleepQuality,
                "hadRestDay": hadRestDay
            ]

            let result = try await functions.httpsCallable("setDailyInputs").call(payload)
            print("✅ setDailyInputs result:", result.data)
        } catch {
            print("❌ setDailyInputs failed:", error)
        }
    }
}
