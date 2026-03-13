//
//  LogActivityView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

struct LogActivityView: View {
    @Binding var selectedTab: MainTabView.Tab

    @State private var showConfirmation = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var type: String = "Strength"
    @State private var duration: Double = 45
    @State private var intensity: Double = 6

    private let functions = Functions.functions()

    private let types = ["Strength", "Run", "Hyrox", "Mobility", "Yoga", "Walk", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }

                    HStack {
                        Text("Duration (min)")
                        Spacer()
                        Text("\(Int(duration))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $duration, in: 5...180, step: 5)

                    HStack {
                        Text("Intensity (1–10)")
                        Spacer()
                        Text("\(Int(intensity))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $intensity, in: 1...10, step: 1)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }

                Section {
                    Button {
                        Task {
                            await saveActivity()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else if showConfirmation {
                            Label("Saved!", systemImage: "checkmark")
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save activity")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Log Activity")
        }
    }

    private func saveActivity() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "You’re not signed in yet. Please try again."
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            let payload: [String: Any] = [
                "dateKey": todayKeyUTC(),
                "durationMinutes": Int(duration),
                "rpe": Int(intensity),
                "modality": backendModality(for: type),
                "sleepHours": 7.5,
                "sleepQuality": 3,
                "baselineSleepHours": 7.5
            ]

            _ = try await functions.httpsCallable("logSession").call(payload)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            showConfirmation = true
            isSaving = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showConfirmation = false
                selectedTab = .dashboard
            }

        } catch {
            isSaving = false
            errorMessage = "Could not save activity. Please try again."
            print("❌ logSession failed:", error)
        }
    }

    private func backendModality(for type: String) -> String {
        switch type {
        case "Hyrox":
            return "HIIT"
        case "Run":
            return "Endurance"
        case "Strength":
            return "Strength"
        case "Mobility", "Yoga", "Walk":
            return "Mobility"
        default:
            return "Endurance"
        }
    }
}
