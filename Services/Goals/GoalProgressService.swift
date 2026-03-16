//
//  GoalProgressService.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class GoalProgressService {

    static func updateProgress(
        for activityType: String,
        distanceKm: Double? = nil
    ) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let goalsRef = db
            .collection("users")
            .document(uid)
            .collection("goals")

        do {
            let snapshot = try await goalsRef
                .whereField("isActive", isEqualTo: true)
                .getDocuments()

            for doc in snapshot.documents {
                guard let goalType = doc.data()["type"] as? String else { continue }

                let increment = incrementValue(
                    for: activityType,
                    goalType: goalType,
                    distanceKm: distanceKm
                )

                guard increment > 0 else { continue }

                try await goalsRef
                    .document(doc.documentID)
                    .updateData([
                        "currentValue": FieldValue.increment(increment)
                    ])
            }
        } catch {
            print("Goal progress update failed:", error)
        }
    }

    private static func incrementValue(
        for activityType: String,
        goalType: String,
        distanceKm: Double?
    ) -> Double {
        switch (activityType, goalType) {
        case ("Strength", "workoutCount"):
            return 1

        case ("Hyrox", "workoutCount"):
            return 1

        case ("Run", "workoutCount"):
            return 1

        case ("Run", "runDistance"):
            return distanceKm ?? 0

        case ("Mobility", "mobilitySessions"):
            return 1

        case ("Yoga", "mobilitySessions"):
            return 1

        default:
            return 0
        }
    }
}
