//
//  LocalStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 08/02/2026.
//


//
//  LocalStore.swift
//  HABITUS
//
//  Created by Ava Thomas on 08/02/2026.
//

import Foundation

enum LocalStore {
    private static let fileName = "metrics.json"

    struct PersistedMetrics: Codable {
        var todayStrain: Double
        var todayActivities: [ActivityLog]
    }

    static func load() -> PersistedMetrics? {
        let url = fileURL()

        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PersistedMetrics.self, from: data)
        } catch {
            print("LocalStore.load error:", error)
            return nil
        }
    }

    static func save(_ metrics: PersistedMetrics) {
        let url = fileURL()

        do {
            let data = try JSONEncoder().encode(metrics)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("LocalStore.save error:", error)
        }
    }

    private static func fileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
}
