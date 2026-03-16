//
//  ScheduledPlanCard.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct ScheduledPlanCard: View {

    let item: ScheduledPlanItem

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {

                VStack(alignment: .leading, spacing: 4) {

                    Text("\(timeFormatter.string(from: item.start)) – \(timeFormatter.string(from: item.end))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(item.item.title)
                        .font(.title3.weight(.semibold))

                    Text(item.item.subtitle)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {

                    Text("\(item.item.durationMinutes) min")
                        .font(.subheadline.weight(.semibold))

                    Text("RPE \(item.item.intensity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(item.item.reason)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}