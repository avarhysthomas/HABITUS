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
        do {
            // 1) Ensure signed in (required for callable functions)
            if Auth.auth().currentUser == nil {
                _ = try await Auth.auth().signInAnonymously()
                print("✅ Signed in anonymously. UID:", Auth.auth().currentUser?.uid ?? "nil")
            }

            // 2) Call the callable function
            let payload: [String: Any] = [
                "dateKey": "2026-02-23",
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
}
