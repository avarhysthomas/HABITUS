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
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HabitusScreenHeader(
                        eyebrow: "Control room",
                        title: "Settings",
                        subtitle: "Keep recovery inputs, privacy, and account controls in one place."
                    )

                    recoveryPanel
                    privacyPanel

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.76))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    updateRecoveryButton
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .background(HabitusStyle.screenBackground)
            .scrollIndicators(.hidden)
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
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

    private var recoveryPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily recovery")
                        .font(.title3.weight(.bold))

                    Text("Manual inputs for today's readiness.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(format: "%.1f h", sleepHours))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(HabitusStyle.teal)
            }

            sliderRow(
                title: "Sleep hours",
                value: String(format: "%.1f", sleepHours),
                slider: Slider(value: $sleepHours, in: 0...12, step: 0.5)
            )

            sliderRow(
                title: "Sleep quality",
                value: "\(Int(sleepQuality))/5",
                slider: Slider(value: $sleepQuality, in: 1...5, step: 1)
            )

            Toggle(isOn: $hadRestDay) {
                Text("Rest day yesterday")
                    .font(.subheadline.weight(.semibold))
            }
            .tint(HabitusStyle.teal)
        }
        .habitusPanel()
    }

    private var privacyPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Privacy & account")
                .font(.title3.weight(.bold))

            Text(
                "HABITUS stores your profile, goals, activity logs, sleep check-ins, strain scores, recovery scores, and Smart Planning outputs in your private Firebase account data."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    session.signOut()
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(HabitusStyle.ink)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Image(systemName: "trash.fill")
                            Text("Delete")
                        }
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.red)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isDeletingAccount)
            }
        }
        .habitusPanel()
    }

    private var updateRecoveryButton: some View {
        Button {
            Task {
                await updateRecovery()
            }
        } label: {
            HStack {
                Spacer()

                if isSaving {
                    ProgressView()
                        .tint(.white)
                } else if showSaved {
                    Label("Updated", systemImage: "checkmark")
                } else {
                    Label("Update recovery", systemImage: "arrow.clockwise")
                }

                Spacer()
            }
            .habitusPrimaryCTA()
        }
        .disabled(isSaving)
    }

    private func sliderRow<SliderView: View>(
        title: String,
        value: String,
        slider: SliderView
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            slider
                .tint(HabitusStyle.teal)
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
