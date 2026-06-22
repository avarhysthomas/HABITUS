//
//  SessionRowView.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import SwiftUI

struct SessionRowView: View {
    let item: SessionRowItem
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.activityType.isEmpty ? item.modality : item.activityType)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(red: 0.06, green: 0.09, blue: 0.12))

                Text("\(item.durationMinutes) min × RPE \(item.rpe)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("+\(String(format: "%.1f", item.score))")
                .font(.headline.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(red: 0.02, green: 0.56, blue: 0.54).opacity(0.12))
                .foregroundStyle(Color(red: 0.02, green: 0.56, blue: 0.54))
                .clipShape(Capsule())

            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.headline)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit \(item.activityType.isEmpty ? item.modality : item.activityType) session")
            }

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.headline)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete \(item.modality) session")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }
}
