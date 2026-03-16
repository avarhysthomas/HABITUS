//
//  DayDashboardStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

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

    @Published var smartPlanSummary: String = ""
    @Published var smartPlanItems: [SmartPlanItem] = []

    @Published var scheduledPlanItems: [ScheduledPlanItem] = []

    private let calendarService = CalendarAvailabilityService()
    private let scheduler = PlanScheduler()

    private var listener: ListenerRegistration?

    func startListening(dateKey: String) {
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

            if let smartPlan = data["smartPlan"] as? [String: Any] {
                self.smartPlanSummary = smartPlan["summary"] as? String ?? ""

                if let rawItems = smartPlan["items"] as? [[String: Any]] {
                    let parsedItems: [SmartPlanItem] = rawItems.compactMap { item in
                        guard
                            let activityType = item["activityType"] as? String,
                            let title = item["title"] as? String,
                            let subtitle = item["subtitle"] as? String,
                            let reason = item["reason"] as? String
                        else {
                            return nil
                        }

                        let durationMinutes: Int
                        if let n = item["durationMinutes"] as? NSNumber {
                            durationMinutes = n.intValue
                        } else if let n = item["durationMinutes"] as? Int {
                            durationMinutes = n
                        } else {
                            durationMinutes = 0
                        }

                        let intensity: Int
                        if let n = item["intensity"] as? NSNumber {
                            intensity = n.intValue
                        } else if let n = item["intensity"] as? Int {
                            intensity = n
                        } else {
                            intensity = 0
                        }

                        return SmartPlanItem(
                            activityType: activityType,
                            title: title,
                            subtitle: subtitle,
                            reason: reason,
                            durationMinutes: durationMinutes,
                            intensity: intensity
                        )
                    }

                    self.smartPlanItems = parsedItems

                    Task {
                        await self.schedulePlanItems(for: dateKey)
                    }
                } else {
                    self.smartPlanItems = []
                    self.scheduledPlanItems = []
                }
            } else {
                self.smartPlanSummary = ""
                self.smartPlanItems = []
                self.scheduledPlanItems = []
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func generateSmartPlan(dateKey: String, goals: [Goal]) async {
        guard Auth.auth().currentUser != nil else { return }

        let functions = Functions.functions(region: "us-central1")

        let payload: [String: Any] = [
            "dateKey": dateKey,
            "goals": goals.map {
                [
                    "type": $0.type.rawValue,
                    "targetValue": $0.targetValue,
                    "currentValue": $0.currentValue
                ]
            },
        ]

        do {
            _ = try await functions
                .httpsCallable("getPlanForUser")
                .call(payload)
        } catch {
            print("generateSmartPlan error:", error)
        }
    }

    func schedulePlanItems(for dateKey: String) async {
        guard !smartPlanItems.isEmpty else {
            scheduledPlanItems = []
            return
        }

        do {
            let granted = try await calendarService.requestAccess()

            guard granted else {
                print("Calendar access denied")
                scheduledPlanItems = []
                return
            }

            let date = dateFromKey(dateKey) ?? Date()
            let slots = calendarService.freeSlots(for: date)

            let scheduled = scheduler.schedule(
                items: smartPlanItems,
                into: slots
            )

            scheduledPlanItems = scheduled
        } catch {
            print("Scheduling error:", error)
            scheduledPlanItems = []
        }
    }

    private func dateFromKey(_ dateKey: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateKey)
    }
}
