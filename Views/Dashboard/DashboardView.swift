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
            ScrollView{
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Today’s log")
                                .font(.headline)
                            Spacer()
                            Text("\(metrics.todayActivities.count)")
                                .foregroundStyle(.secondary)
                        }

                        if metrics.todayActivities.isEmpty {
                            Text("No activities logged yet.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 6)
                        } else {
                            ForEach(metrics.todayActivities) { item in
                                ActivityRow(item: item)
                            }
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 12)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}
