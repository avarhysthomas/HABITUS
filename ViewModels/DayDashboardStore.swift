//
//  DayDashboardStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DayDashboardStore: ObservableObject {
    @Published var strainScore: Double = 0.0
    @Published var recoveryScore: Double? = nil
    @Published var recoveryGuidance: String = "Add sleep soon"

    private var listener: ListenerRegistration?

    func startListening(dateKey: String) {
        Task {
            if Auth.auth().currentUser == nil {
                _ = try? await Auth.auth().signInAnonymously()
            }

            guard let uid = Auth.auth().currentUser?.uid else { return }

            listener?.remove()

            let ref = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("days")
                .document(dateKey)

            listener = ref.addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    print("Day listener error:", error)
                    return
                }

                guard let data = snapshot?.data() else { return }

                if let strain = data["strain"] as? [String: Any] {
                    if let score = strain["score"] as? NSNumber {
                        self.strainScore = score.doubleValue
                    } else if let score = strain["score"] as? Double {
                        self.strainScore = score
                    }
                }

                if let recovery = data["recovery"] as? [String: Any] {
                    if let score = recovery["score"] as? NSNumber {
                        self.recoveryScore = score.doubleValue
                    } else if let score = recovery["score"] as? Double {
                        self.recoveryScore = score
                    }

                    if let guidance = recovery["guidance"] as? String {
                        self.recoveryGuidance = guidance
                    }
                } else {
                    self.recoveryScore = nil
                    self.recoveryGuidance = "Add sleep soon"
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
