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
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily check-in")
                        .font(.largeTitle.bold())

                    Text("Log your sleep first so HABITUS can calculate recovery and build today’s plan.")
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sleep Hours")
                            Spacer()
                            Text(String(format: "%.1f", sleepHours))
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $sleepHours, in: 0...12, step: 0.5)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sleep Quality")
                            Spacer()
                            Text("\(Int(sleepQuality))/5")
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $sleepQuality, in: 1...5, step: 1)
                    }

                    Toggle("Rest Day Yesterday", isOn: $hadRestDay)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }

                Button {
                    Task { await saveInputs() }
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Save check-in")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSaving)

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
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
