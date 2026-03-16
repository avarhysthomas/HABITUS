//
//  TodaySessionsStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct SessionRowItem: Identifiable {
    let id: String
    let modality: String
    let durationMinutes: Int
    let rpe: Int
    let score: Double
}

@MainActor
final class TodaySessionsStore: ObservableObject {
    @Published var sessions: [SessionRowItem] = []

    private var listener: ListenerRegistration?

    func startListening(dateKey: String) {
        Task {
            if Auth.auth().currentUser == nil {
                _ = try? await Auth.auth().signInAnonymously()
            }

            guard let uid = Auth.auth().currentUser?.uid else {
                print("No authenticated user yet.")
                return
            }

            listener?.remove()

            let ref = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("sessions")
                .whereField("dateKey", isEqualTo: dateKey)
                .order(by: "createdAt", descending: true)

            listener = ref.addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("Sessions listener error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []
                self.sessions = docs.compactMap { doc in
                    let data = doc.data()

                    let modality = data["modality"] as? String ?? "Session"
                    let durationMinutes = (data["durationMinutes"] as? NSNumber)?.intValue ?? 0
                    let rpe = (data["rpe"] as? NSNumber)?.intValue ?? 0

                    let strain = data["strain"] as? [String: Any]
                    let score = (strain?["score"] as? NSNumber)?.doubleValue ?? 0

                    return SessionRowItem(
                        id: doc.documentID,
                        modality: modality,
                        durationMinutes: durationMinutes,
                        rpe: rpe,
                        score: score
                    )
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
