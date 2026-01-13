//
//  SessionViewModel.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var isOnboarded: Bool = false

    // Later: userId, auth state, Firestore user doc, etc.
    func completeOnboarding() {
        isOnboarded = true
    }
}
