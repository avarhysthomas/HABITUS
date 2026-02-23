//
//  FirebaseEmulatorConfig.swift
//  HABITUS
//
//  Created by Ava Thomas on 23/02/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

enum FirebaseEmulatorConfig {
    static func connect() {
        // Auth emulator
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)

        // Firestore emulator
        let db = Firestore.firestore()
        let settings = db.settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        db.settings = settings

        // Functions emulator
        Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
    }
}
