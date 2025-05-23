//
//  PromptBuilderTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

final class PromptBuilderTests: XCTestCase {
    
    func testPromptBuilder() {
        // Given: Verse details
        let bookDisplay = "Psalms"
        let chapter = "23"
        let verse = "4"
        let verseText = "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me."
        let today = "May 23, 2025"
        
        // When: We build the prompt
        let prompt = PromptBuilder.buildPrompt(
            bookDisplay: bookDisplay,
            chapter: chapter,
            verse: verse,
            verseText: verseText,
            today: today
        )
        
        // Then: The prompt should contain all the necessary elements
        XCTAssertTrue(prompt.contains(bookDisplay))
        XCTAssertTrue(prompt.contains(chapter))
        XCTAssertTrue(prompt.contains(verse))
        XCTAssertTrue(prompt.contains(verseText))
        XCTAssertTrue(prompt.contains(today))
        XCTAssertTrue(prompt.contains("JSON"))  // Verify it requests JSON format
    }
}
