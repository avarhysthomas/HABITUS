//
//  MainTabView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import Foundation
import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: Tab = .dashboard
    @StateObject private var dailyCheckInStore = DailyCheckInStore()

    private var todayDateKey: String {
        DayKey.todayUTC()
    }

    enum Tab: Hashable {
        case dashboard, log, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.dashboard)

            LogActivityView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Log", systemImage: "plus.circle")
                }
                .tag(Tab.log)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .task {
            await dailyCheckInStore.checkTodaySleepStatus(dateKey: todayDateKey)
        }
        .sheet(isPresented: $dailyCheckInStore.shouldPresentSleepCheckIn) {
            SleepCheckInView(dateKey: todayDateKey) {
                dailyCheckInStore.markComplete()
                NotificationCenter.default.post(
                    name: Notification.Name("dailyInputsSaved"),
                    object: nil
                )
            }
            .presentationDetents([.medium, .large])
            .interactiveDismissDisabled()
        }
    }
}
