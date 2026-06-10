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
        Form {
            Section("Create account") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                SecureField("Confirm password", text: $confirmPassword)
            }

            OnboardingProfileForm(profile: $profile)

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await signUp() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create account")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Sign up")
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
            Form {
                Section {
                    Text("Complete your HABITUS profile")
                        .font(.title2.weight(.semibold))

                    Text("These answers personalise your dashboard and Smart Planning recommendations.")
                        .foregroundStyle(.secondary)
                }

                OnboardingProfileForm(profile: $profile)

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save profile")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Profile")
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
        Section("Personalisation") {
            Picker("Office Athlete level", selection: $profile.officeAthleteLevel) {
                ForEach(OnboardingProfileData.officeAthleteLevels, id: \.self) {
                    Text($0)
                }
            }

            Picker("Work location", selection: $profile.workLocation) {
                ForEach(OnboardingProfileData.workLocations, id: \.self) {
                    Text($0)
                }
            }

            Picker("Primary goal", selection: $profile.primaryGoal) {
                ForEach(OnboardingProfileData.primaryGoals, id: \.self) {
                    Text($0)
                }
            }
        }

        Section("Baseline") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Typical sleep")
                    Spacer()
                    Text(String(format: "%.1f hours", profile.baselineSleepHours))
                        .foregroundStyle(.secondary)
                }

                Slider(value: $profile.baselineSleepHours, in: 0...12, step: 0.5)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Typical stress")
                    Spacer()
                    Text("\(Int(profile.baselineStress))/5")
                        .foregroundStyle(.secondary)
                }

                Slider(value: $profile.baselineStress, in: 1...5, step: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Typical energy")
                    Spacer()
                    Text("\(Int(profile.baselineEnergy))/5")
                        .foregroundStyle(.secondary)
                }

                Slider(value: $profile.baselineEnergy, in: 1...5, step: 1)
            }
        }
    }
}
