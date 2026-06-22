//
//  HabitusStyle.swift
//  HABITUS
//
//  Created by Ava Thomas on 22/06/2026.
//

import SwiftUI

enum HabitusStyle {
    static let ink = Color(red: 0.05, green: 0.08, blue: 0.11)
    static let deepTeal = Color(red: 0.04, green: 0.16, blue: 0.18)
    static let teal = Color(red: 0.02, green: 0.56, blue: 0.54)
    static let mint = Color(red: 0.43, green: 0.86, blue: 0.58)
    static let blue = Color(red: 0.02, green: 0.50, blue: 0.98)

    static var screenBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.98, blue: 0.97),
                Color(red: 0.90, green: 0.94, blue: 0.98),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                deepTeal,
                Color(red: 0.02, green: 0.33, blue: 0.32),
                mint
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct HabitusScreenHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(HabitusStyle.ink)
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.78))
                .clipShape(Capsule())

            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(HabitusStyle.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HabitusPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.84), lineWidth: 1)
            )
            .shadow(color: HabitusStyle.ink.opacity(0.05), radius: 18, x: 0, y: 10)
    }
}

private struct HabitusPrimaryCTAModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.headline.weight(.bold))
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        HabitusStyle.ink,
                        HabitusStyle.teal
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: HabitusStyle.teal.opacity(0.22), radius: 18, x: 0, y: 10)
    }
}

private struct HabitusTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .font(.body.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.76))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.86), lineWidth: 1)
            )
    }
}

extension View {
    func habitusPanel(cornerRadius: CGFloat = 22) -> some View {
        modifier(HabitusPanelModifier(cornerRadius: cornerRadius))
    }

    func habitusPrimaryCTA(cornerRadius: CGFloat = 18) -> some View {
        modifier(HabitusPrimaryCTAModifier(cornerRadius: cornerRadius))
    }

    func habitusTextField() -> some View {
        modifier(HabitusTextFieldModifier())
    }
}
