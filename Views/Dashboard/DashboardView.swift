//
//  DashboardView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dayStore = DayDashboardStore()
    @StateObject private var sessionsStore = TodaySessionsStore()

    private var today: String {
        DayKey.todayUTC()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Today")
                        .font(.title2.bold())

                    VStack(spacing: 16) {
                        MetricRing(
                            title: "Strain",
                            valueText: String(format: "%.1f", dayStore.strainScore),
                            subtitle: strainSubtitle,
                            progress: min(dayStore.strainScore / 21.0, 1.0)
                        )

                        MetricRing(
                            title: "Recovery",
                            valueText: recoveryValueText,
                            subtitle: dayStore.recoveryGuidance.isEmpty ? "Add sleep soon" : dayStore.recoveryGuidance,
                            progress: recoveryProgress,
                            color: recoveryColor
                        )
                    }

                    if !dayStore.recommendationTitle.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recommended today")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(dayStore.recommendationTitle)
                                    .font(.title3.weight(.semibold))

                                Text(dayStore.recommendationSubtitle)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Today’s log")
                                .font(.headline)

                            Spacer()

                            Text("\(dayStore.sessionCount)")
                                .foregroundStyle(.secondary)
                        }

                        if sessionsStore.sessions.isEmpty {
                            Text("No activities logged yet.")
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 6)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(sessionsStore.sessions) { item in
                                    SessionRowView(item: item)
                                }
                            }
                        }
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 12)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                dayStore.startListening(dateKey: today)
                sessionsStore.startListening(dateKey: today)
            }
            .onDisappear {
                dayStore.stopListening()
                sessionsStore.stopListening()
            }
        }
    }

    private var recoveryValueText: String {
        guard let score = dayStore.recoveryScore else { return "--" }
        return String(format: "%.0f", score)
    }

    private var recoveryProgress: Double {
        guard let score = dayStore.recoveryScore else { return 0 }
        return min(max(score / 100.0, 0), 1)
    }

    private var recoveryColor: Color {
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

    private var strainSubtitle: String {
        switch dayStore.strainScore {
        case ..<0.1:
            return "Log an activity to begin"
        case ..<7:
            return "Light day so far"
        case ..<14:
            return "Training load in range"
        default:
            return "High load — prioritise recovery"
        }
    }
}
