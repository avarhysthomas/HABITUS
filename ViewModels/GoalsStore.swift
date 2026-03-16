//
//  GoalsStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class GoalsStore: ObservableObject {
    @Published var goals: [Goal] = []

    private var listener: ListenerRegistration?

    func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener?.remove()

        listener = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("goals")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("Goals listener error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []

                self.goals = docs.compactMap { doc in
                    let data = doc.data()

                    guard
                        let rawType = data["type"] as? String,
                        let type = GoalType(rawValue: rawType)
                    else {
                        return nil
                    }

                    let targetValue =
                        (data["targetValue"] as? NSNumber)?.doubleValue ??
                        (data["targetValue"] as? Double) ??
                        0

                    let currentValue =
                        (data["currentValue"] as? NSNumber)?.doubleValue ??
                        (data["currentValue"] as? Double) ??
                        0

                    let isActive = data["isActive"] as? Bool ?? true
                    let weekStart = data["weekStart"] as? String

                    return Goal(
                        id: doc.documentID,
                        type: type,
                        targetValue: targetValue,
                        currentValue: currentValue,
                        isActive: isActive,
                        weekStart: weekStart
                    )
                }
                .sorted { $0.type.title < $1.type.title }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func saveGoal(
        type: GoalType,
        targetValue: Double,
        currentValue: Double = 0
    ) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let ref = db
            .collection("users")
            .document(uid)
            .collection("goals")

        let existing = goals.first(where: { $0.type == type })

        let payload: [String: Any] = [
            "type": type.rawValue,
            "targetValue": targetValue,
            "currentValue": currentValue,
            "isActive": true,
            "weekStart": DayKey.todayUTC(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        do {
            if let existing {
                try await ref.document(existing.id).setData(payload, merge: true)
            } else {
                var createPayload = payload
                createPayload["createdAt"] = FieldValue.serverTimestamp()
                _ = try await ref.addDocument(data: createPayload)
            }
        } catch {
            print("saveGoal error:", error)
        }
    }
}