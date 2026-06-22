//
//  SmartPlanCard.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI

struct SmartPlanCard: View {
    let item: SmartPlanItem
    var isFeatured: Bool = false

    private var accentColor: Color {
        switch item.activityType {
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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: iconName)
                            .font(.caption.weight(.bold))

                        Text(item.activityType.uppercased())
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isFeatured ? Color.white.opacity(0.14) : accentColor.opacity(0.12))
                    .foregroundStyle(isFeatured ? .white : accentColor)
                    .clipShape(Capsule())

                    Text(item.title)
                        .font(.system(size: isFeatured ? 26 : 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isFeatured ? .white : Color(red: 0.06, green: 0.09, blue: 0.12))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isFeatured ? .white.opacity(0.84) : .secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.durationMinutes) min")
                        .font(.headline.weight(.bold))

                    Text("RPE \(item.intensity)")
                        .font(.caption)
                        .foregroundStyle(isFeatured ? .white.opacity(0.65) : .secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(isFeatured ? Color.white.opacity(0.16) : Color.black.opacity(0.05))
                .foregroundStyle(isFeatured ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(item.reason)
                .font(.subheadline)
                .foregroundStyle(isFeatured ? .white.opacity(0.84) : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(isFeatured ? 22 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isFeatured ? Color.white.opacity(0.18) : Color.white.opacity(0.9), lineWidth: 1)
        )
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

    private var iconName: String {
        switch item.activityType {
        case "recovery":
            return "leaf"
        case "mobility":
            return "figure.flexibility"
        case "meditation":
            return "sparkles"
        case "run":
            return "figure.run"
        case "walk":
            return "figure.walk"
        default:
            return "bolt.fill"
        }
    }
}
