//
//  RecoveryRequest.swift
//  HABITUS
//
//  Created by Ava Thomas on 11/02/2026.
//


import Foundation

struct RecoveryRequest: Encodable {
    let yesterdayStrain: Double
    let sleepHours: Double
    let hadRestDay: Bool
}

struct RecoveryResponse: Decodable {
    let score: Int
    let state: String
    let guidance: String
}

enum RecoveryAPIError: Error {
    case badURL
    case badResponse(Int)
}

final class RecoveryAPI {

    // Emulator URL (Simulator -> your Mac uses 127.0.0.1 fine)
    private let baseURL = "http://127.0.0.1:5001/habitus-v1/us-central1/recovery"

    func computeRecovery(input: RecoveryRequest) async throws -> RecoveryResponse {
        guard let url = URL(string: baseURL) else { throw RecoveryAPIError.badURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(input)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw RecoveryAPIError.badResponse(-1)
        }
        guard (200...299).contains(http.statusCode) else {
            throw RecoveryAPIError.badResponse(http.statusCode)
        }

        return try JSONDecoder().decode(RecoveryResponse.self, from: data)
    }
}
