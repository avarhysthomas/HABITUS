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
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Welcome to HABITUS")
                        .font(.system(size: 34, weight: .bold))

                    Text("Sign in to track strain, recovery, and training guidance.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                Spacer()

                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Create account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                NavigationLink {
                    SignInView()
                } label: {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
        }
    }
}