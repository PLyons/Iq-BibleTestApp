//
//  DevotionalCacheManagerTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

final class DevotionalCacheManagerTests: XCTestCase {
    
    var cacheManager: DevotionalCacheManager!
    var sampleDevotional: Devotional!
    let testReference = "Test 1:1"
    
    override func setUp() {
        super.setUp()
        
        // Create a new instance of the cache manager for testing
        cacheManager = DevotionalCacheManager.shared
        
        // Create a sample devotional
        sampleDevotional = Devotional(
            title: "Test Title",
            subtitle: "Test Subtitle",
            reference: testReference,
            verse: "Test verse text",
            contextualBackground: "Test background",
            historicalInsights: "Test history",
            linguisticInsights: "Test linguistics",
            modernRelevance: "Test relevance",
            reflectionQuestions: ["Question 1", "Question 2"],
            prayer: "Test prayer"
        )
        
        // Clear cache before each test
        cacheManager.clearCache()
    }
    
    override func tearDown() {
        // Clear cache after each test
        cacheManager.clearCache()
        super.tearDown()
    }
    
    func testCacheDevotional() {
        // Given: A sample devotional and reference
        
        // When: We cache the devotional
        cacheManager.cacheDevotional(sampleDevotional, forReference: testReference)
        
        // Then: We should be able to retrieve it from cache
        let cachedDevotional = cacheManager.getCachedDevotional(forReference: testReference)
        XCTAssertNotNil(cachedDevotional)
        XCTAssertEqual(cachedDevotional?.title, sampleDevotional.title)
        XCTAssertEqual(cachedDevotional?.verse, sampleDevotional.verse)
    }
    
    func testGetCachedDevotionalMissing() {
        // Given: An empty cache
        
        // When: We try to retrieve a devotional that doesn't exist
        let cachedDevotional = cacheManager.getCachedDevotional(forReference: "Nonexistent 1:1")
        
        // Then: It should return nil
        XCTAssertNil(cachedDevotional)
    }
    
    func testRemoveFromCache() {
        // Given: A cached devotional
        cacheManager.cacheDevotional(sampleDevotional, forReference: testReference)
        
        // When: We remove it from cache
        cacheManager.removeFromCache(reference: testReference)
        
        // Then: It should no longer be retrievable
        let cachedDevotional = cacheManager.getCachedDevotional(forReference: testReference)
        XCTAssertNil(cachedDevotional)
    }
    
    func testClearCache() {
        // Given: Multiple cached devotionals
        cacheManager.cacheDevotional(sampleDevotional, forReference: testReference)
        cacheManager.cacheDevotional(sampleDevotional, forReference: "Another 2:2")
        
        // When: We clear the cache
        cacheManager.clearCache()
        
        // Then: All devotionals should be removed
        XCTAssertNil(cacheManager.getCachedDevotional(forReference: testReference))
        XCTAssertNil(cacheManager.getCachedDevotional(forReference: "Another 2:2"))
    }
    
    func testCacheTimestamp() {
        // Given: A cached devotional
        cacheManager.cacheDevotional(sampleDevotional, forReference: testReference)
        
        // When: We get the cache timestamp
        let timestamp = cacheManager.getCacheTime(forReference: testReference)
        
        // Then: It should be a recent timestamp
        XCTAssertNotNil(timestamp)
        
        if let timestamp = timestamp {
            let now = Date()
            let timeDifference = now.timeIntervalSince(timestamp)
            XCTAssertLessThan(timeDifference, 5) // Should be less than 5 seconds old
        }
    }
}
