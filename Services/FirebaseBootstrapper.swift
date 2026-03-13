//
//  FirebaseBootstrapper.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

@MainActor
final class FirebaseBootstrapper: ObservableObject {
    @Published var isReady = false
    @Published var uid: String?

    func start() async {
        // 1. Connect to emulators first
        #if DEBUG
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)

        let db = Firestore.firestore()
        let settings = db.settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        settings.isPersistenceEnabled = false
        db.settings = settings

        Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
        #endif

        // 2. Force clean auth in debug
        #if DEBUG
        try? Auth.auth().signOut()
        #endif

        // 3. Sign in anonymously
        do {
            let result = try await Auth.auth().signInAnonymously()
            self.uid = result.user.uid
            print("✅ Signed in anonymously:", result.user.uid)
            self.isReady = true
        } catch {
            print("❌ Anonymous sign-in failed:", error)
            self.isReady = false
        }
    }
}