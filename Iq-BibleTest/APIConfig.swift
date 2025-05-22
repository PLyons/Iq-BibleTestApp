//
//  APIConfig.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

enum APIConfig {
    static var groqKey: String {
        getKey(named: "GROQ_API_KEY")
    }
    static var iqBibleKey: String {
        getKey(named: "IQ-BIBLE_API_KEY")
    }

    private static func getKey(named name: String) -> String {
        guard
            let url = Bundle.main.url(forResource: "APIConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = dict[name] as? String
        else {
            fatalError("Missing or invalid API key for \(name)")
        }
        return key
    }
}
