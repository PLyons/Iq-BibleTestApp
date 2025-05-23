//
//  BibleVerseTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

final class BibleVerseTests: XCTestCase {
    
    func testBibleVerseDecoding() throws {
        // Given: A sample JSON string representing a Bible verse
        let jsonString = """
        {
            "b": 19,
            "c": 23,
            "v": 4,
            "t": "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me."
        }
        """
        
        // When: We decode the JSON
        let jsonData = Data(jsonString.utf8)
        let verse = try JSONDecoder().decode(BibleVerse.self, from: jsonData)
        
        // Then: All properties should be correctly parsed
        XCTAssertEqual(verse.b, "19")
        XCTAssertEqual(verse.bookName, "Psalms") // Assuming book name mapping works correctly
        XCTAssertEqual(verse.c, "23")
        XCTAssertEqual(verse.v, "4")
        XCTAssertEqual(verse.t, "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me.")
    }
    
    func testBibleVerseReference() {
        // Given: A Bible verse instance
        let verse = BibleVerse(b: "19", c: "23", v: "4", t: "Sample verse text")
        
        // When/Then: The reference should be formatted correctly
        XCTAssertEqual(verse.reference, "Psalms 23:4")
    }
}
