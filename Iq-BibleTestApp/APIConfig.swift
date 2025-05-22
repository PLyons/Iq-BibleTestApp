// APIConfig.swift
// Iq-BibleTestApp
// Created by Paul Lyons on 5/22/25.

import Foundation

class APIConfig {
    static let shared = APIConfig()
    private var config: [String: Any] = [:]

    private init() {
        if let url = Bundle.main.url(forResource: "APIConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            config = dict
        }
    }

    var groqAPIKey: String? {
        config["GROQ_API_KEY"] as? String
    }

    var iqBibleAPIKey: String? {
        config["IQ-BIBLE_API_KEY"] as? String
    }
}
