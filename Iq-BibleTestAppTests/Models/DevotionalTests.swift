//
//  DevotionalTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp  // Use actual module name

final class DevotionalTests: XCTestCase {
    
    func testDevotionalDecoding() throws {
        // Given: A sample JSON string representing a devotional
        let jsonString = """
        {
            "title": "Finding Peace in Chaos",
            "subtitle": "God's Presence in Uncertain Times",
            "reference": "Psalms 23:4",
            "verse": "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me.",
            "contextualBackground": "Psalm 23 was written by David, who knew what it meant to face danger and difficulty.",
            "historicalInsights": "Shepherds in ancient Israel would use rods for protection against wild animals.",
            "linguisticInsights": "The Hebrew word for 'valley' here implies a deep, dark ravine.",
            "modernRelevance": "Today, we face our own valleys of uncertainty and fear.",
            "reflectionQuestions": [
                "When have you felt God's presence in difficult times?",
                "How does the image of God as shepherd speak to you?"
            ],
            "prayer": "Lord, thank you for walking with me through life's dark valleys."
        }
        """
        
        // When: We decode the JSON
        let jsonData = Data(jsonString.utf8)
        let devotional = try JSONDecoder().decode(Devotional.self, from: jsonData)
        
        // Then: All properties should be correctly parsed
        XCTAssertEqual(devotional.title, "Finding Peace in Chaos")
        XCTAssertEqual(devotional.subtitle, "God's Presence in Uncertain Times")
        XCTAssertEqual(devotional.reference, "Psalms 23:4")
        XCTAssertEqual(devotional.verse, "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me.")
        XCTAssertEqual(devotional.contextualBackground, "Psalm 23 was written by David, who knew what it meant to face danger and difficulty.")
        XCTAssertEqual(devotional.historicalInsights, "Shepherds in ancient Israel would use rods for protection against wild animals.")
        XCTAssertEqual(devotional.linguisticInsights, "The Hebrew word for 'valley' here implies a deep, dark ravine.")
        XCTAssertEqual(devotional.modernRelevance, "Today, we face our own valleys of uncertainty and fear.")
        XCTAssertEqual(devotional.reflectionQuestions.count, 2)
        XCTAssertEqual(devotional.reflectionQuestions[0], "When have you felt God's presence in difficult times?")
        XCTAssertEqual(devotional.reflectionQuestions[1], "How does the image of God as shepherd speak to you?")
        XCTAssertEqual(devotional.prayer, "Lord, thank you for walking with me through life's dark valleys.")
    }
    
    func testInvalidDevotionalJSON() {
        // Given: An invalid JSON string (missing required fields)
        let invalidJSON = """
        {
            "title": "Incomplete Devotional",
            "subtitle": "Missing Fields"
        }
        """
        
        // When/Then: Decoding should throw an error
        let data = Data(invalidJSON.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Devotional.self, from: data))
    }
}
