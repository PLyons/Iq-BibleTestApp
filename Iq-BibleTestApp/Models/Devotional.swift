//
//  Devotional.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

struct Devotional: Codable {
    let title: String
    let subtitle: String
    let reference: String
    let verse: String
    let contextualBackground: String
    let historicalInsights: String
    let linguisticInsights: String
    let modernRelevance: String
    let reflectionQuestions: [String]
    let prayer: String

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case reference
        case verse
        case contextualBackground = "contextual_background"
        case historicalInsights = "historical_insights"
        case linguisticInsights = "linguistic_insights"
        case modernRelevance = "modern_relevance"
        case reflectionQuestions = "reflection_questions"
        case prayer
    }
}
