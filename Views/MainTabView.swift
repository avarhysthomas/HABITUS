//
//  MainTabView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }

            LogActivityView()
                .tabItem { Label("Log", systemImage: "plus.circle") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
