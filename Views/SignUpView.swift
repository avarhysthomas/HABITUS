//
//  SignUpView.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Create account") {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("Password", text: $password)
                SecureField("Confirm password", text: $confirmPassword)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await signUp() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create account")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Sign up")
    }

    private func signUp() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            isLoading = false
            dismiss()
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}