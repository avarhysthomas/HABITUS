//
//  SettingsView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var sleepHours: Double = 7.5
    @State private var sleepQuality: Double = 3
    @State private var hadRestDay: Bool = false

    @State private var isSaving = false
    @State private var isDeletingAccount = false
    @State private var showSaved = false
    @State private var showDeleteConfirmation = false
    @State private var errorMessage: String?

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

                    Toggle("Rest Day Yesterday", isOn: $hadRestDay)
                }

                Section("Planning") {
                    NavigationLink {
                        GoalsView()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly Goals")
                            Text("Set training, run, mobility, and meditation targets")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Privacy & Account") {
                    Text(
                        "HABITUS stores your profile, goals, activity logs, sleep check-ins, strain scores, recovery scores, and Smart Planning outputs in your private Firebase account data."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Button("Sign Out") {
                        session.signOut()
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Text("Delete Account and Data")
                        }
                    }
                    .disabled(isDeletingAccount)
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
            .alert("Delete account and data?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { await deleteAccountData() }
                }
            } message: {
                Text("This permanently deletes your HABITUS profile, goals, daily metrics, sessions, and Firebase account.")
            }
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
                "dateKey": DayKey.today(),
                "sleepHours": sleepHours,
                "sleepQuality": Int(sleepQuality),
                "hadRestDay": hadRestDay
            ]

            try await FirebaseCallableRunner.callVoid(
                "setDailyInputs",
                payload: payload
            )

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

    private func deleteAccountData() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "You’re not signed in yet. Please try again."
            return
        }

        isDeletingAccount = true
        errorMessage = nil

        do {
            try await FirebaseCallableRunner.callVoid(
                "deleteAccountData",
                payload: [:]
            )

            session.signOut()
        } catch {
            errorMessage = "Failed to delete account data. Please try again."
            print("❌ deleteAccountData failed:", error)
        }

        isDeletingAccount = false
    }
}
