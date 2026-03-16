//
//  SmartPlan.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation

struct SmartPlan: Codable {
    let summary: String
    let items: [SmartPlanItem]
}

struct SmartPlanItem: Codable, Identifiable {
    let activityType: String
    let title: String
    let subtitle: String
    let reason: String
    let durationMinutes: Int
    let intensity: Int

    var id: String {
        "\(activityType)-\(title)-\(durationMinutes)-\(intensity)"
    }
}

struct SmartPlanResponse: Codable {
    let dateKey: String
    let smartPlan: SmartPlan
}
