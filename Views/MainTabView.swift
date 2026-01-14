//
//  MainTabView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab: Hashable {
        case dashboard, log, settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(Tab.dashboard)

            LogActivityView(selectedTab: $selectedTab)
                .tabItem { Label("Log", systemImage: "plus.circle") }
                .tag(Tab.log)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}
