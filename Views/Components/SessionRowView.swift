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
                    .font(.title3.weight(.semibold))

                Text("\(item.durationMinutes) min × RPE \(item.rpe)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("+\(String(format: "%.1f", item.score))")
                .font(.headline.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.12))
                .foregroundStyle(.blue)
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
                .fill(Color(.secondarySystemBackground))
        )
    }
}
