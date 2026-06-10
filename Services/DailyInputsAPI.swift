//
//  DailyInputsAPI.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation
@preconcurrency import FirebaseFunctions

enum FirebaseCallableRunner {
    static func callVoid(
        _ name: String,
        payload: [String: Any],
        region: String = "us-central1"
    ) async throws {
        let callable = Functions.functions(region: region)
            .httpsCallable(name)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            callable.call(payload) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

final class DailyInputsAPI {
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

        try await FirebaseCallableRunner.callVoid(
            "setDailyInputs",
            payload: payload
        )
    }
}
