//
//  SettingsView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFunctions

struct SettingsView: View {
    @State private var sleepHours: Double = 7.5
    @State private var sleepQuality: Double = 3
    @State private var hadRestDay: Bool = false

    @State private var isSaving = false
    @State private var showSaved = false
    @State private var errorMessage: String?

    private let functions = Functions.functions()

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Recovery") {
                    HStack {
                        Text("Sleep Hours")
                        Spacer()
                        Text(String(format: "%.1f", sleepHours))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $sleepHours, in: 0...12, step: 0.5)

                    HStack {
                        Text("Sleep Quality")
                        Spacer()
                        Text("\(Int(sleepQuality))/5")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $sleepQuality, in: 1...5, step: 1)

                    Toggle("Rest Day", isOn: $hadRestDay)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            await updateRecovery()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else if showSaved {
                            Label("Updated!", systemImage: "checkmark")
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Update Recovery")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func updateRecovery() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "You’re not signed in yet. Please try again."
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            let payload: [String: Any] = [
                "dateKey": DayKey.todayUTC(),
                "sleepHours": sleepHours,
                "sleepQuality": Int(sleepQuality),
                "hadRestDay": hadRestDay,
            ]

            _ = try await functions
                .httpsCallable("setDailyInputs")
                .call(payload)

            isSaving = false
            showSaved = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showSaved = false
            }
        } catch {
            isSaving = false
            errorMessage = "Failed to update recovery. Please try again."
            print("❌ setDailyInputs failed:", error)
        }
    }
}
