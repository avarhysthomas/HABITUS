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
            VStack(alignment: .leading, spacing: 24) {
                Text("Weekly goals")
                    .font(.largeTitle.bold())

                goalCard(
                    title: "Workout Count",
                    value: workoutCount,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                goalCard(
                    title: "Run Distance",
                    value: runDistance,
                    range: 0...100,
                    step: 1,
                    unit: "km"
                )

                goalCard(
                    title: "Mobility Sessions",
                    value: mobilitySessions,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                goalCard(
                    title: "Meditation Sessions",
                    value: meditationSessions,
                    range: 0...14,
                    step: 1,
                    unit: "sessions"
                )

                Button("Save goals") {
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
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear {
            goalsStore.startListening()
            hydrateFromExistingGoals()
        }
        .onDisappear {
            goalsStore.stopListening()
        }
        .onChange(of: goalsStore.goals) { _ in
            hydrateFromExistingGoals()
        }
    }

    @ViewBuilder
    private func goalCard(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        step: Double,
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(value)) \(unit)")
                    .foregroundStyle(.secondary)
            }

            switch title {
            case "Workout Count":
                Slider(value: $workoutCount, in: range, step: step)
            case "Run Distance":
                Slider(value: $runDistance, in: range, step: step)
            case "Mobility Sessions":
                Slider(value: $mobilitySessions, in: range, step: step)
            default:
                Slider(value: $meditationSessions, in: range, step: step)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
