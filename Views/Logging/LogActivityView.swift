//
//  LogActivityView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI
import FirebaseAuth

struct LogActivityView: View {
    @Binding var selectedTab: MainTabView.Tab

    @State private var showConfirmation = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var type: String = "Strength"
    @State private var duration: Double = 45
    @State private var distanceKm: Double = 5
    @State private var intensity: Double = 6

    private let types = ["Strength", "Run", "Hyrox", "Mobility", "Yoga", "Walk", "Other"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HabitusScreenHeader(
                        eyebrow: "Activity log",
                        title: "Log movement",
                        subtitle: "Capture the work you did so strain, goals, and planning stay honest."
                    )
                    activityTypePanel
                    sessionLoadPanel

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.76))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button {
                        Task {
                            await saveActivity()
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else if showConfirmation {
                                Label("Saved", systemImage: "checkmark")
                            } else {
                                Label("Save activity", systemImage: "plus.circle.fill")
                            }

                            Spacer()
                        }
                        .habitusPrimaryCTA()
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 30)
            }
            .background(HabitusStyle.screenBackground)
            .scrollIndicators(.hidden)
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var activityTypePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Activity type")
                .font(.title3.weight(.bold))

            Picker("Type", selection: $type) {
                ForEach(types, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .habitusPanel()
    }

    private var sessionLoadPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Session load")
                        .font(.title3.weight(.bold))

                    Text("Duration and effort shape today's strain score.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("RPE \(Int(intensity))")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(HabitusStyle.teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(HabitusStyle.teal.opacity(0.12))
                    .clipShape(Capsule())
            }

            sliderRow(
                title: "Duration",
                value: "\(Int(duration)) min",
                slider: Slider(value: $duration, in: 5...180, step: 5)
            )

            if type == "Run" {
                sliderRow(
                    title: "Distance",
                    value: String(format: "%.1f km", distanceKm),
                    slider: Slider(value: $distanceKm, in: 0.5...30, step: 0.5)
                )
            }

            sliderRow(
                title: "Intensity",
                value: "\(Int(intensity))/10",
                slider: Slider(value: $intensity, in: 1...10, step: 1)
            )
        }
        .habitusPanel()
    }

    private func sliderRow<SliderView: View>(
        title: String,
        value: String,
        slider: SliderView
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }

            slider
        }
    }

    private func saveActivity() async {
        guard Auth.auth().currentUser != nil else {
            errorMessage = "You’re not signed in yet. Please try again."
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            let payload: [String: Any] = [
                "dateKey": DayKey.today(),
                "durationMinutes": Int(duration),
                "rpe": Int(intensity),
                "modality": backendModality(for: type),
                "baselineSleepHours": 7.5,
                "activityType": type,
                "distanceKm": type == "Run" ? distanceKm : 0,
            ]

            try await FirebaseCallableRunner.callVoid(
                "logSession",
                payload: payload
            )

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            showConfirmation = true
            isSaving = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showConfirmation = false
                selectedTab = .dashboard
            }

        } catch {
            isSaving = false
            errorMessage = "Could not save activity. Please try again."
            print("❌ logSession failed:", error)
        }
    }

    private func backendModality(for type: String) -> String {
        switch type {
        case "Hyrox":
            return "HIIT"
        case "Run":
            return "Endurance"
        case "Strength":
            return "Strength"
        case "Mobility", "Yoga", "Walk":
            return "Mobility"
        default:
            return "Endurance"
        }
    }
}
