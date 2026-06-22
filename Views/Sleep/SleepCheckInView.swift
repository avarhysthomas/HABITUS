//
//  SleepCheckInView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import SwiftUI

struct SleepCheckInView: View {
    @Environment(\.dismiss) private var dismiss

    let dateKey: String
    let onSaved: () -> Void

    @State private var sleepHours: Double = 7.5
    @State private var sleepQuality: Double = 3
    @State private var hadRestDay = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HabitusScreenHeader(
                        eyebrow: "Recovery input",
                        title: "Daily check-in",
                        subtitle: "Log sleep first so recovery and today's plan start from real data."
                    )

                    recoveryHero

                    VStack(alignment: .leading, spacing: 18) {
                        sliderRow(
                            title: "Sleep hours",
                            value: String(format: "%.1f h", sleepHours),
                            slider: Slider(value: $sleepHours, in: 0...12, step: 0.5)
                        )

                        sliderRow(
                            title: "Sleep quality",
                            value: "\(Int(sleepQuality))/5",
                            slider: Slider(value: $sleepQuality, in: 1...5, step: 1)
                        )

                        Toggle(isOn: $hadRestDay) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rest day yesterday")
                                    .font(.subheadline.weight(.semibold))

                                Text("Feeds the recovery calculation before planning.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(HabitusStyle.teal)
                    }
                    .habitusPanel()

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
                        Task { await saveInputs() }
                    } label: {
                        HStack {
                            Spacer()

                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Label("Save check-in", systemImage: "checkmark.circle.fill")
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
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var recoveryHero: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recovery baseline")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text("\(String(format: "%.1f", sleepHours)) hours")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Quality \(Int(sleepQuality))/5")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer()

            Image(systemName: hadRestDay ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 78, height: 78)
                .background(Color.white.opacity(0.18))
                .clipShape(Circle())
        }
        .padding(22)
        .background(HabitusStyle.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: HabitusStyle.teal.opacity(0.22), radius: 22, x: 0, y: 12)
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
                .tint(HabitusStyle.teal)
        }
    }

    private func saveInputs() async {
        isSaving = true
        errorMessage = nil

        do {
            try await DailyInputsAPI().save(
                dateKey: dateKey,
                sleepHours: sleepHours,
                sleepQuality: Int(sleepQuality),
                hadRestDay: hadRestDay
            )

            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
