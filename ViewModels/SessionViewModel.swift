//
//  SessionViewModel.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import Foundation

@MainActor
final class SessionViewModel: ObservableObject {

    @Published var isOnboarded: Bool {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: Keys.isOnboarded) }
    }

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: Keys.isOnboarded)
    }

    func completeOnboarding() {
        isOnboarded = true
    }

    func resetOnboarding() {
        isOnboarded = false
    }

    private enum Keys {
        static let isOnboarded = "isOnboarded"
    }
}
