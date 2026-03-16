//
//  RootView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionViewModel()

    var body: some View {
        Group {
            if session.isOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(session)
    }
}
