//
//  GoalProgressRow.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct GoalProgressRow: View {
    let title: String
    let currentValue: Double
    let targetValue: Double
    let unit: String

    private var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }

    private var valueText: String {
        if unit == "km" {
            return "\(String(format: "%.1f", currentValue)) / \(String(format: "%.1f", targetValue)) \(unit)"
        } else {
            return "\(Int(currentValue)) / \(Int(targetValue)) \(unit)"
        }
    }
    
    private var isComplete: Bool {
        currentValue >= targetValue && targetValue > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isComplete ? .green : .primary)

                Spacer()

                Text(valueText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(.blue)
        }
        
        if isComplete {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
}
