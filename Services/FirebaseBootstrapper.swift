//
//  FirebaseBootstrapper.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/03/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

@MainActor
final class FirebaseBootstrapper: ObservableObject {
    @Published var isReady = false

    private let useEmulators = false

    func start() async {
        configureFirebaseTargets()
        isReady = true
    }

    private func configureFirebaseTargets() {
        guard useEmulators else { return }

        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)

        let db = Firestore.firestore()
        let settings = db.settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        settings.isPersistenceEnabled = false
        db.settings = settings

        Functions.functions(region: "us-central1")
            .useEmulator(withHost: "127.0.0.1", port: 5001)
    }
}
