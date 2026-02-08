//
//  ActivityRow.swift
//  HABITUS
//
//  Created by Ava Thomas on 14/01/2026.
//

import SwiftUI

struct ActivityRow: View {
    let item: ActivityLog
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName(for: item.type))
                .font(.title3)
                .frame(width: 28)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.type)
                    .font(.headline)
                
                Text("\(item.durationMinutes) min X Intensity \(item.intensty)/10")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("+\(String(format: "%.1f", item.strainAdded))")
                .font(.subheadline.weight(.semibold))
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func iconName(for type: String) -> String {
        switch type{
        case "Run": return "figure.run"
        case "Walk": return "figure.walk"
        case "Strength": return "dumbbell"
        case "Hyrox": return "flame"
        case "Mobility", "Yoga": return "figure.cooldown"
        default: return "bolt"
        }
    }
}
