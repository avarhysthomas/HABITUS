//
//  SessionViewModel.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var isOnboarded: Bool
    @Published var isCheckingProfile: Bool
    @Published var user: User?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        let currentUser = Auth.auth().currentUser
        self.isOnboarded = false
        self.isCheckingProfile = currentUser != nil
        self.user = currentUser

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                await self?.refreshProfileStatus()
            }
        }
    }

    var isSignedIn: Bool {
        user != nil
    }

    func refreshProfileStatus() async {
        guard let user else {
            isOnboarded = false
            isCheckingProfile = false
            return
        }

        isCheckingProfile = true
        defer { isCheckingProfile = false }

        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .getDocument()

            let completed = document.data()?["onboardingCompleted"] as? Bool ?? false
            isOnboarded = completed
            UserDefaults.standard.set(completed, forKey: "isOnboarded")
        } catch {
            print("❌ Profile status check failed:", error)
            isOnboarded = false
        }
    }

    func saveProfile(
        _ profile: OnboardingProfileData,
        email: String? = nil
    ) async throws {
        guard let user else { return }

        let resolvedEmail = email ?? user.email ?? ""
        let payload: [String: Any] = [
            "email": resolvedEmail,
            "officeAthleteLevel": profile.officeAthleteLevel,
            "workLocation": profile.workLocation,
            "primaryGoal": profile.primaryGoal,
            "baselineSleepHours": profile.baselineSleepHours,
            "baselineStress": profile.baselineStress,
            "baselineEnergy": profile.baselineEnergy,
            "onboardingCompleted": true,
            "updatedAt": FieldValue.serverTimestamp(),
            "createdAt": FieldValue.serverTimestamp()
        ]

        try await Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .setData(payload, merge: true)

        isOnboarded = true
        UserDefaults.standard.set(true, forKey: "isOnboarded")
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Sign out failed:", error)
        }
    }

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
}
