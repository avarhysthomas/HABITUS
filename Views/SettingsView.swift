//
//  SettingsView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct SettingsView: View {
    private let tester = BackendTest()

    @State private var sleepHours: Double = 7.5
    @State private var sleepQuality: Double = 3
    @State private var hadRestDay: Bool = false

    @State private var isSaving = false
    @State private var showSaved = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Recovery") {
                    HStack {
                        Text("Sleep Hours")
                        Spacer()
                        Text(String(format: "%.1f", sleepHours))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $sleepHours, in: 0...12, step: 0.5)

                    HStack {
                        Text("Sleep Quality")
                        Spacer()
                        Text("\(Int(sleepQuality))/5")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $sleepQuality, in: 1...5, step: 1)

                    Toggle("Rest Day", isOn: $hadRestDay)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            await updateRecovery()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else if showSaved {
                            Label("Updated!", systemImage: "checkmark")
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Update Recovery")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSaving)
                }

#if DEBUG
                Section("Debug") {
                    Button("Run logSession test") {
                        Task { await tester.runLogSessionTest() }
                    }

                    Button("Run setDailyInputs test") {
                        Task {
                            await tester.runSetDailyInputs(
                                sleepHours: sleepHours,
                                sleepQuality: Int(sleepQuality),
                                hadRestDay: hadRestDay
                            )
                        }
                    }
                }
#endif
            }
            .navigationTitle("Settings")
        }
    }

    private func updateRecovery() async {
        isSaving = true
        errorMessage = nil

        await tester.runSetDailyInputs(
            sleepHours: sleepHours,
            sleepQuality: Int(sleepQuality),
            hadRestDay: hadRestDay
        )

        isSaving = false
        showSaved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSaved = false
        }
    }
}
