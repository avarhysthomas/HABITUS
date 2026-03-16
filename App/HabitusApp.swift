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
    @StateObject private var bootstrapper = FirebaseBootstrapper()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if bootstrapper.isReady {
                    RootView()
                } else {
                    ProgressView("Connecting to backend...")
                        .task {
                            await bootstrapper.start()
                        }
                }
            }
        }
    }
}
