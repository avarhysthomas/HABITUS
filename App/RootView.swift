//
//  RootView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionViewModel()
    @StateObject private var metrics = MetricsStore()

    var body: some View {
        Group {
            if session.isOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(session)
        .environmentObject(metrics)
    }
}
