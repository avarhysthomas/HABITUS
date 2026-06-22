//
//  SignInView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HabitusScreenHeader(
                    eyebrow: "Welcome back",
                    title: "Sign in",
                    subtitle: "Pick up your readiness, goals, and planned sessions."
                )

                VStack(alignment: .leading, spacing: 14) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .habitusTextField()

                    SecureField("Password", text: $password)
                        .habitusTextField()
                }
                .habitusPanel()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.76))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Button {
                    Task { await signIn() }
                } label: {
                    HStack {
                        Spacer()

                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Sign in", systemImage: "arrow.right.circle.fill")
                        }

                        Spacer()
                    }
                    .habitusPrimaryCTA()
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 30)
        }
        .background(HabitusStyle.screenBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signIn() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoading = false
            dismiss()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
