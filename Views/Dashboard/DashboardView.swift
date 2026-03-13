//
//  DashboardView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var metrics: MetricsStore
    @StateObject private var dayStore = DayDashboardStore()
    @StateObject private var sessionsStore = TodaySessionsStore()
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today")
                        .font(.title2).bold()
                    
                        .onAppear {
                            let today = todayKeyUTC()
                            dayStore.startListening(dateKey: today)
                            sessionsStore.startListening(dateKey: today)
                        }
                        .onDisappear {
                            dayStore.stopListening()
                            sessionsStore.stopListening()
                        }
                    
                    VStack(spacing: 16) {
                        MetricRing(
                            title: "Strain",
                            valueText: String(format: "%.1f", dayStore.strainScore),
                            subtitle: dayStore.strainScore > 14 ? "High load — prioritise recovery" : "Training load in range",
                            progress: dayStore.strainScore / 21.0
                        )

                        MetricRing(
                            title: "Recovery",
                            valueText: dayStore.recoveryScore == nil ? "--" : String(format: "%.0f", dayStore.recoveryScore!),
                            subtitle: dayStore.recoveryGuidance.isEmpty ? "Add sleep soon" : dayStore.recoveryGuidance,
                            progress: (dayStore.recoveryScore ?? 0) / 100.0,
                            color: recoveryColor
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Today’s log")
                                .font(.headline)
                            Spacer()
                            Text("\(sessionsStore.sessions.count)")
                                .foregroundStyle(.secondary)
                        }

                        if sessionsStore.sessions.isEmpty {
                            Text("No activities logged yet.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 6)
                        } else {
                            ForEach(sessionsStore.sessions) { item in
                                SessionRowView(item: item)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.top, 4)
                    .padding(.top, 4)

                    Spacer(minLength: 12)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
        
        var recoveryColor: Color {
            guard let score = dayStore.recoveryScore else {
                return .gray
            }

            if score >= 70 {
                return .green
            } else if score >= 40 {
                return .orange
            } else {
                return .red
            }
        }
        
    }
}
