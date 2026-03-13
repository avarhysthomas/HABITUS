//
//  MetricRing.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import SwiftUI

struct MetricRing: View {
    let title: String
    let valueText: String
    let subtitle: String
    let progress: Double
    var color: Color? = nil

    private var defaultRingColor: Color {
        switch progress {
        case 0..<0.33: return .blue
        case 0.33..<0.66: return .green
        case 0.66..<0.85: return .orange
        default: return .red
        }
    }

    private var ringColor: Color {
        color ?? defaultRingColor
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: max(0, min(progress, 1)))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: progress)

                VStack(spacing: 2) {
                    Text(valueText)
                        .font(.title2.bold())
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 92, height: 92)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
