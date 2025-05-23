//
//  DevotionalTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

class DevotionalTests: XCTestCase {
    
    func testDevotionalDecoding() throws {
        // Given: JSON for a devotional with snake_case keys matching CodingKeys
        let json = """
        {
            "title": "Finding Peace",
            "subtitle": "God's Comfort",
            "reference": "Psalms 23:4",
            "verse": "Test verse text",
            "contextual_background": "Test background",
            "historical_insights": "Test history",
            "linguistic_insights": "Test linguistics",
            "modern_relevance": "Test relevance",
            "reflection_questions": ["Question 1", "Question 2"],
            "prayer": "Test prayer"
        }
        """
        
        // When: We decode the JSON into a Devotional
        let data = json.data(using: .utf8)!
        let devotional = try JSONDecoder().decode(Devotional.self, from: data)
        
        // Then: The properties should match
        XCTAssertEqual(devotional.title, "Finding Peace")
        XCTAssertEqual(devotional.subtitle, "God's Comfort")
        XCTAssertEqual(devotional.reference, "Psalms 23:4")
        XCTAssertEqual(devotional.verse, "Test verse text")
        XCTAssertEqual(devotional.contextualBackground, "Test background")
        XCTAssertEqual(devotional.historicalInsights, "Test history")
        XCTAssertEqual(devotional.linguisticInsights, "Test linguistics")
        XCTAssertEqual(devotional.modernRelevance, "Test relevance")
        XCTAssertEqual(devotional.reflectionQuestions.count, 2)
        XCTAssertEqual(devotional.reflectionQuestions[0], "Question 1")
        XCTAssertEqual(devotional.reflectionQuestions[1], "Question 2")
        XCTAssertEqual(devotional.prayer, "Test prayer")
    }
    
    func testDevotionalEncoding() throws {
        // Given: A devotional object
        let devotional = Devotional(
            title: "Sample Title",
            subtitle: "Sample Subtitle",
            reference: "Psalms 23:4",
            verse: "Test verse",
            contextualBackground: "Background",
            historicalInsights: "History",
            linguisticInsights: "Linguistics",
            modernRelevance: "Relevance",
            reflectionQuestions: ["Q1", "Q2"],
            prayer: "Prayer"
        )
        
        // When: We encode the devotional to JSON
        let data = try JSONEncoder().encode(devotional)
        
        // Then: We should be able to decode it back
        let decodedDevotional = try JSONDecoder().decode(Devotional.self, from: data)
        
        XCTAssertEqual(decodedDevotional.title, devotional.title)
        XCTAssertEqual(decodedDevotional.subtitle, devotional.subtitle)
        XCTAssertEqual(decodedDevotional.reference, devotional.reference)
    }
}
