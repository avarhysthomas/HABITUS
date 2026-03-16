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
    @Published var sessionCount: Int = 0

    @Published var recoveryScore: Double? = nil
    @Published var recoveryState: String = "--"
    @Published var recoveryGuidance: String = "Add sleep soon"

    @Published var recommendationTitle: String = ""
    @Published var recommendationSubtitle: String = ""
    @Published var recommendationType: String = ""

    private var listener: ListenerRegistration?

    func startListening(dateKey: String) {
        Task {

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

                let data = snapshot?.data() ?? [:]

                if let strain = data["strain"] as? [String: Any] {
                    if let score = strain["score"] as? NSNumber {
                        self.strainScore = score.doubleValue
                    } else if let score = strain["score"] as? Double {
                        self.strainScore = score
                    } else {
                        self.strainScore = 0
                    }

                    if let count = strain["sessionCount"] as? NSNumber {
                        self.sessionCount = count.intValue
                    } else {
                        self.sessionCount = 0
                    }
                } else {
                    self.strainScore = 0
                    self.sessionCount = 0
                }

                if let recovery = data["recovery"] as? [String: Any] {
                    if let score = recovery["score"] as? NSNumber {
                        self.recoveryScore = score.doubleValue
                    } else if let score = recovery["score"] as? Double {
                        self.recoveryScore = score
                    } else {
                        self.recoveryScore = nil
                    }

                    self.recoveryState = recovery["state"] as? String ?? "--"
                    self.recoveryGuidance = recovery["guidance"] as? String ?? "Add sleep soon"
                } else {
                    self.recoveryScore = nil
                    self.recoveryState = "--"
                    self.recoveryGuidance = "Add sleep soon"
                }

                if let recommendation = data["recommendation"] as? [String: Any] {
                    self.recommendationTitle = recommendation["title"] as? String ?? ""
                    self.recommendationSubtitle = recommendation["subtitle"] as? String ?? ""
                    self.recommendationType = recommendation["type"] as? String ?? ""
                } else {
                    self.recommendationTitle = ""
                    self.recommendationSubtitle = ""
                    self.recommendationType = ""
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
