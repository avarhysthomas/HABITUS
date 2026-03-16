//
//  DailyInputsAPI.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation
import FirebaseFunctions

final class DailyInputsAPI {
    private let functions = Functions.functions(region: "us-central1")

    func save(
        dateKey: String,
        sleepHours: Double,
        sleepQuality: Int,
        hadRestDay: Bool
    ) async throws {
        let payload: [String: Any] = [
            "dateKey": dateKey,
            "sleepHours": sleepHours,
            "sleepQuality": sleepQuality,
            "hadRestDay": hadRestDay
        ]

        _ = try await functions
            .httpsCallable("setDailyInputs")
            .call(payload)
    }
}