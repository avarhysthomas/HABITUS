//
//  DashboardView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var metrics: MetricsStore

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today")
                    .font(.title2).bold()

                StatCard(
                    title: "Strain",
                    value: String(format: "%.1f", metrics.todayStrain),
                    subtitle: metrics.strainSubtitle
                )

                StatCard(
                    title: "Recovery",
                    value: metrics.recoveryText,
                    subtitle: metrics.recoverySubtitle
                )

                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
