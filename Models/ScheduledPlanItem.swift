//
//  ScheduledPlanItem.swift
//  HABITUS
//
//  Created by Ava Thomas on 16/03/2026.
//


import Foundation

struct ScheduledPlanItem: Identifiable {
    let id = UUID()
    let item: SmartPlanItem
    let start: Date
    let end: Date
}
