//
//  BibleVerseTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

class BibleVerseTests: XCTestCase {
    
    func testBibleVerseDecoding() throws {
        // Given: JSON for a Bible verse
        let json = """
        {
            "b": "19",
            "c": "23",
            "v": "4",
            "t": "Test verse text"
        }
        """
        
        // When: We decode the JSON into a BibleVerse
        let data = json.data(using: .utf8)!
        let verse = try JSONDecoder().decode(BibleVerse.self, from: data)
        
        // Then: The properties should match
        XCTAssertEqual(verse.b, "19")
        XCTAssertEqual(verse.c, "23")
        XCTAssertEqual(verse.v, "4")
        XCTAssertEqual(verse.t, "Test verse text")
    }
    
    func testBibleVerseReference() {
        // Given: A Bible verse
        let verse = BibleVerse(b: "19", c: "23", v: "4", t: "Test verse text")
        
        // When/Then: The reference should be formatted correctly
        XCTAssertEqual(verse.bookName, "Psalms")
        
        // Check full reference
        let fullRef = "\(verse.bookName) \(verse.c):\(verse.v)"
        XCTAssertEqual(fullRef, "Psalms 23:4")
    }
}
