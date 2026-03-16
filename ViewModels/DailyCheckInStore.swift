//
//  DailyCheckInStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DailyCheckInStore: ObservableObject {
    @Published var shouldPresentSleepCheckIn = false
    @Published var isChecking = false

    func checkTodaySleepStatus(dateKey: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        isChecking = true
        defer { isChecking = false }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("days")
                .document(dateKey)
                .getDocument()

            let data = doc.data() ?? [:]
            let inputs = data["inputs"] as? [String: Any]

            let sleepHours = inputs?["sleepHours"] as? NSNumber
            let sleepQuality = inputs?["sleepQuality"] as? NSNumber

            let hasSleepHours = (sleepHours?.doubleValue ?? 0) > 0
            let hasSleepQuality = (sleepQuality?.intValue ?? 0) >= 1

            shouldPresentSleepCheckIn = !(hasSleepHours && hasSleepQuality)
        } catch {
            print("DailyCheckInStore error:", error)
            shouldPresentSleepCheckIn = true
        }
    }

    func markComplete() {
        shouldPresentSleepCheckIn = false
    }
}
