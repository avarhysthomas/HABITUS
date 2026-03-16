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
            VStack(alignment: .leading, spacing: 6) {
                Text(item.modality)
                    .font(.title3.weight(.semibold))

                Text("\(item.durationMinutes) min × RPE \(item.rpe)")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("+\(String(format: "%.1f", item.score))")
                .font(.title3.weight(.bold))
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
