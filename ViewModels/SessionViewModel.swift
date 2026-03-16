//
//  SessionViewModel.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import Foundation
import FirebaseAuth

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var isOnboarded: Bool
    @Published var user: User?

    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.user = Auth.auth().currentUser

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    var isSignedIn: Bool {
        user != nil
    }

    func completeOnboarding() {
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
