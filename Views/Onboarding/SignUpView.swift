//
//  SignUpView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import SwiftUI
import FirebaseAuth

struct OnboardingProfileData: Equatable {
    var officeAthleteLevel: String = OnboardingProfileData.officeAthleteLevels[1]
    var workLocation: String = OnboardingProfileData.workLocations[1]
    var primaryGoal: String = OnboardingProfileData.primaryGoals[0]
    var baselineSleepHours: Double = 7.5
    var baselineStress: Double = 3
    var baselineEnergy: Double = 3

    static let officeAthleteLevels = [
        "New to exercise",
        "Building consistency",
        "Regular mover",
        "Training 4+ times weekly",
        "Performance focused"
    ]

    static let workLocations = [
        "Office",
        "Hybrid",
        "Remote"
    ]

    static let primaryGoals = [
        "Increase activity",
        "Reduce stress",
        "Improve recovery",
        "Build routine",
        "Support performance"
    ]
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var profile = OnboardingProfileData()

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HabitusScreenHeader(
                    eyebrow: "Profile setup",
                    title: "Create account",
                    subtitle: "Set the baseline HABITUS uses to personalise your first plan."
                )

                accountPanel
                OnboardingProfileForm(profile: $profile)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.76))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Button {
                    Task { await signUp() }
                } label: {
                    HStack {
                        Spacer()

                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Create account", systemImage: "person.crop.circle.badge.plus")
                        }

                        Spacer()
                    }
                    .habitusPrimaryCTA()
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .background(HabitusStyle.screenBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var accountPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account")
                .font(.title3.weight(.bold))

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .habitusTextField()

            SecureField("Password", text: $password)
                .habitusTextField()

            SecureField("Confirm password", text: $confirmPassword)
                .habitusTextField()
        }
        .habitusPanel()
    }

    private func signUp() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let authResult = try await Auth.auth().createUser(
                withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )

            try await session.saveProfile(
                profile,
                email: authResult.user.email ?? email
            )

            isLoading = false
            dismiss()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}

struct ProfileSetupView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var profile = OnboardingProfileData()
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HabitusScreenHeader(
                        eyebrow: "Personalisation",
                        title: "Complete profile",
                        subtitle: "These answers shape dashboard copy and Smart Planning recommendations."
                    )

                    OnboardingProfileForm(profile: $profile)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.76))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button {
                        Task { await saveProfile() }
                    } label: {
                        HStack {
                            Spacer()

                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Label("Save profile", systemImage: "checkmark.circle.fill")
                            }

                            Spacer()
                        }
                        .habitusPrimaryCTA()
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .background(HabitusStyle.screenBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveProfile() async {
        isSaving = true
        errorMessage = nil

        do {
            try await session.saveProfile(profile)
        } catch {
            errorMessage = "Could not save your profile. Please try again."
        }

        isSaving = false
    }
}

private struct OnboardingProfileForm: View {
    @Binding var profile: OnboardingProfileData

    var body: some View {
        VStack(spacing: 18) {
            personalisationPanel
            baselinePanel
        }
    }

    private var personalisationPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Personalisation")
                .font(.title3.weight(.bold))

            pickerRow(
                title: "Office Athlete level",
                selection: $profile.officeAthleteLevel,
                options: OnboardingProfileData.officeAthleteLevels
            )

            pickerRow(
                title: "Work location",
                selection: $profile.workLocation,
                options: OnboardingProfileData.workLocations
            )

            pickerRow(
                title: "Primary goal",
                selection: $profile.primaryGoal,
                options: OnboardingProfileData.primaryGoals
            )
        }
        .habitusPanel()
    }

    private var baselinePanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Baseline")
                .font(.title3.weight(.bold))

            sliderRow(
                title: "Typical sleep",
                value: String(format: "%.1f hours", profile.baselineSleepHours),
                slider: Slider(value: $profile.baselineSleepHours, in: 0...12, step: 0.5)
            )

            sliderRow(
                title: "Typical stress",
                value: "\(Int(profile.baselineStress))/5",
                slider: Slider(value: $profile.baselineStress, in: 1...5, step: 1)
            )

            sliderRow(
                title: "Typical energy",
                value: "\(Int(profile.baselineEnergy))/5",
                slider: Slider(value: $profile.baselineEnergy, in: 1...5, step: 1)
            )
        }
        .habitusPanel()
    }

    private func pickerRow(
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            Picker(title, selection: selection) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
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
}
