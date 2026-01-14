//
//  LogActivityView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI

struct LogActivityView: View {
    @EnvironmentObject private var metrics: MetricsStore
    @Binding var selectedTab: MainTabView.Tab
    
    @State private var showConfirmation = false
    @State private var type: String = "Strength"
    @State private var duration: Double = 45
    @State private var intensity: Double = 6
    
    private let types = ["Strength", "Run", "Hyrox", "Mobility", "Yoga", "Walk", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }
                    
                    HStack {
                        Text("Duration (min)")
                        Spacer()
                        Text("\(Int(duration))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $duration, in: 5...180, step: 5)
                    
                    HStack {
                        Text("Intensity (1–10)")
                        Spacer()
                        Text("\(Int(intensity))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $intensity, in: 1...10, step: 1)
                }
                
                Section {
                    Button{
                        metrics.logActivity(type: type, durationMinutes: duration, intensity: intensity)
                        
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        showConfirmation = true
                        
                        //Small switch delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showConfirmation = false
                            selectedTab = .dashboard
                        }
                    } label: {
                        if showConfirmation {
                            Label("Saved!", systemImage: "checkmark")
                                .foregroundColor(.green)
                        } else {
                            Text("Save activity")
                        }
                    }
                }
            }
        }
    }
}
