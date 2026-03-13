//
//  SessionRowView.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//


import SwiftUI

struct SessionRowView: View {
    let item: SessionRowItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.modalityLabel)
                    .font(.headline)

                Text("\(item.durationMinutes) min X Intensity \(item.rpe)/10")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(String(format: "+%.1f", item.score))
                .font(.headline)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private extension SessionRowItem {
    var modalityLabel: String {
        switch modality {
        case "HIIT": return "Hyrox"
        case "Endurance": return "Run"
        case "Strength": return "Strength"
        case "Mobility": return "Mobility"
        default: return modality
        }
    }
}
