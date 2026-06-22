//
//  ScheduledPlanCard.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct ScheduledPlanCard: View {

    let item: ScheduledPlanItem
    var isFeatured: Bool = false

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    private var accentColor: Color {
        switch item.item.activityType {
        case "recovery", "mobility", "meditation":
            return Color(red: 0.23, green: 0.77, blue: 0.50)
        case "run", "walk":
            return Color(red: 0.05, green: 0.48, blue: 0.92)
        default:
            return Color(red: 0.02, green: 0.56, blue: 0.54)
        }
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            HStack {

                VStack(alignment: .leading, spacing: 8) {

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption.weight(.bold))

                        Text("\(timeFormatter.string(from: item.start)) - \(timeFormatter.string(from: item.end))")
                            .font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isFeatured ? Color.white.opacity(0.14) : accentColor.opacity(0.12))
                    .foregroundStyle(isFeatured ? .white : accentColor)
                    .clipShape(Capsule())

                    Text(item.item.title)
                        .font(.system(size: isFeatured ? 26 : 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isFeatured ? .white : Color(red: 0.06, green: 0.09, blue: 0.12))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.item.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isFeatured ? .white.opacity(0.84) : .secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {

                    Text("\(item.item.durationMinutes) min")
                        .font(.subheadline.weight(.semibold))

                    Text("RPE \(item.item.intensity)")
                        .font(.caption)
                        .foregroundStyle(isFeatured ? .white.opacity(0.65) : .secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isFeatured ? Color.white.opacity(0.16) : Color.black.opacity(0.05))
                .foregroundStyle(isFeatured ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(item.item.reason)
                .font(.subheadline)
                .foregroundStyle(isFeatured ? .white.opacity(0.84) : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(isFeatured ? 22 : 20)
        .background(cardGradient)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isFeatured ? Color.white.opacity(0.18) : Color.white.opacity(0.9), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: isFeatured ? accentColor.opacity(0.22) : Color.clear, radius: 16, x: 0, y: 8)
    }

    private var cardGradient: LinearGradient {
        if isFeatured {
            return LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.09, blue: 0.12),
                    Color(red: 0.02, green: 0.28, blue: 0.30),
                    accentColor.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color.white.opacity(0.94),
                accentColor.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
