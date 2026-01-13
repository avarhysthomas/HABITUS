//
//  OnboardingView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var name: String = ""
    @State private var goal: String = "Consistency"

    private let goals = ["Consistency", "Energy", "Strength", "Stress reduction", "Sleep"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Welcome") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                Section("Primary goal") {
                    Picker("Goal", selection: $goal) {
                        ForEach(goals, id: \.self) { Text($0) }
                    }
                }

                Section {
                    Button("Get started") {
                        // Later: persist profile to Firestore
                        session.completeOnboarding()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("HABITUS")
        }
    }
}
