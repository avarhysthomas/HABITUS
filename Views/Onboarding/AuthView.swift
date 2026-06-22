//
//  AuthView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("HABITUS")
                            .font(.caption.weight(.bold))
                            .tracking(1.4)
                            .foregroundStyle(.white.opacity(0.84))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.16))
                            .clipShape(Capsule())

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Office athlete")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Track recovery, strain, and the next practical session for your workday.")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.78))
                        }

                        HStack(spacing: 10) {
                            authMetric(title: "Readiness", value: "daily")
                            authMetric(title: "Planning", value: "smart")
                            authMetric(title: "Habits", value: "steady")
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(HabitusStyle.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: HabitusStyle.teal.opacity(0.22), radius: 24, x: 0, y: 12)

                    VStack(spacing: 12) {
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Label("Create account", systemImage: "person.crop.circle.badge.plus")
                                .habitusPrimaryCTA()
                        }

                        NavigationLink {
                            SignInView()
                        } label: {
                            Label("Sign in", systemImage: "arrow.right.circle.fill")
                                .font(.headline.weight(.bold))
                                .padding(.vertical, 16)
                                .foregroundStyle(HabitusStyle.ink)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.82))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 26)
                .padding(.bottom, 30)
            }
            .background(HabitusStyle.screenBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func authMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))

            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
