//
//  GoalsView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct GoalsView: View {
    @StateObject private var goalsStore = GoalsStore()

    @State private var workoutCount: Double = 4
    @State private var runDistance: Double = 10
    @State private var mobilitySessions: Double = 3
    @State private var meditationSessions: Double = 3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HabitusScreenHeader(
                    eyebrow: "Planning",
                    title: "Weekly goals",
                    subtitle: "Tune the targets HABITUS uses when matching sessions to your week."
                )

                goalsSummaryCard

                goalCard(
                    title: "Workout count",
                    value: $workoutCount,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                goalCard(
                    title: "Run distance",
                    value: $runDistance,
                    range: 0...100,
                    step: 1,
                    unit: "km"
                )

                goalCard(
                    title: "Mobility sessions",
                    value: $mobilitySessions,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                goalCard(
                    title: "Meditation sessions",
                    value: $meditationSessions,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                Button {
                    Task {
                        await goalsStore.saveGoal(
                            type: .workoutCount,
                            targetValue: workoutCount
                        )
                        await goalsStore.saveGoal(
                            type: .runDistance,
                            targetValue: runDistance
                        )
                        await goalsStore.saveGoal(
                            type: .mobilitySessions,
                            targetValue: mobilitySessions
                        )
                        await goalsStore.saveGoal(
                            type: .meditationSessions,
                            targetValue: meditationSessions
                        )
                    }
                } label: {
                    Label("Save goals", systemImage: "target")
                        .habitusPrimaryCTA()
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .background(HabitusStyle.screenBackground)
        .scrollIndicators(.hidden)
        .onAppear {
            goalsStore.startListening()
            hydrateFromExistingGoals()
        }
        .onDisappear {
            goalsStore.stopListening()
        }
        .onChange(of: goalsStore.goals) {
            hydrateFromExistingGoals()
        }
    }

    private var goalsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Office athlete week")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Targets set the guardrails for Smart Planning.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer()

                Text("\(Int(workoutCount))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            HStack(spacing: 10) {
                summaryPill(title: "Run", value: "\(Int(runDistance)) km")
                summaryPill(title: "Mobility", value: "\(Int(mobilitySessions))")
                summaryPill(title: "Mind", value: "\(Int(meditationSessions))")
            }
        }
        .padding(22)
        .background(HabitusStyle.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: HabitusStyle.teal.opacity(0.22), radius: 22, x: 0, y: 12)
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func goalCard(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))

                Spacer()

                Text("\(Int(value.wrappedValue)) \(unit)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            Slider(value: value, in: range, step: step)
                .tint(HabitusStyle.teal)
        }
        .habitusPanel()
    }

    private func hydrateFromExistingGoals() {
        for goal in goalsStore.goals {
            switch goal.type {
            case .workoutCount:
                workoutCount = goal.targetValue
            case .runDistance:
                runDistance = goal.targetValue
            case .mobilitySessions:
                mobilitySessions = goal.targetValue
            case .meditationSessions:
                meditationSessions = goal.targetValue
            }
        }
    }
}
