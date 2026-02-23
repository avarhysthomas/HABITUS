//
//  SettingsView.swift
//  HABITUS
//
//  Created by Ava Thomas on 13/01/2026.
//


import SwiftUI

struct SettingsView: View {
            private var tester = BackendTest()

            var body: some View {
                Button("Run logSession test") {
                    Task { await tester.runLogSessionTest() }
                }
                .padding()
            }
        }
