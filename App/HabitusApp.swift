//
//  HabitusApp.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//

import SwiftUI
import FirebaseCore

@main
struct HABITUSApp: App {
    init() {
        FirebaseApp.configure()
        
    #if DEBUG
    FirebaseEmulatorConfig.connect()
    #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
