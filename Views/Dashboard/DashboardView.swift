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
    @StateObject private var goalsStore = GoalsStore()
    @State private var selectedDate: Date = Date()

    private var selectedDateKey: String {
        DayKey.from(date: selectedDate)
    }

    private var selectedDayTitle: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(selectedDate) {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(selectedDayTitle)
                        .font(.title2.bold())

                    WeekStripView(selectedDate: $selectedDate)

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
                            subtitle: dayStore.recoveryGuidance.isEmpty ?
                                "Add sleep soon" :
                                dayStore.recoveryGuidance,
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

                    if !dayStore.smartPlanItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Smart Plan")
                                .font(.headline)

                            if !dayStore.smartPlanSummary.isEmpty {
                                Text(dayStore.smartPlanSummary)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 14) {
                                ForEach(dayStore.scheduledPlanItems) { item in
                                    ScheduledPlanCard(item: item)
                                }
                            }
                        }
                    }

                    if !goalsStore.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Weekly Progress")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 14) {
                                ForEach(goalsStore.goals) { goal in
                                    GoalProgressRow(
                                        title: goal.type.title,
                                        currentValue: goal.currentValue,
                                        targetValue: goal.targetValue,
                                        unit: goal.type.unit
                                    )
                                }
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Day log")
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
                dayStore.startListening(dateKey: selectedDateKey)
                sessionsStore.startListening(dateKey: selectedDateKey)
                goalsStore.startListening()

                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("dailyInputsSaved")
                )
            ) { _ in
                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                }
            }
            .onChange(of: goalsStore.goals) { _ in
                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                }
            }
            .onChange(of: selectedDate) { _ in
                dayStore.stopListening()
                sessionsStore.stopListening()

                dayStore.startListening(dateKey: selectedDateKey)
                sessionsStore.startListening(dateKey: selectedDateKey)

                Task {
                    await dayStore.generateSmartPlan(dateKey: selectedDateKey)
                }
            }
            .onDisappear {
                dayStore.stopListening()
                sessionsStore.stopListening()
                goalsStore.stopListening()
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
