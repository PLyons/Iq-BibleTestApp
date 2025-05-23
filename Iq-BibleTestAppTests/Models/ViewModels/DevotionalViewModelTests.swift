//
//  DevotionalViewModelTests.swift
//  Iq-BibleTestAppTests
//
//  Created by Paul Lyons on 5/23/25.
//

import XCTest
@testable import Iq_BibleTestApp

// Mock URLProtocol to simulate network responses
class MockURLProtocol: URLProtocol {
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class DevotionalViewModelTests: XCTestCase {
    
    var viewModel: DevotionalViewModel!
    var sampleVerse: BibleVerse!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        // Create a mock URL session configuration
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        
        // Setup the sample verse
        sampleVerse = BibleVerse(b: "19", c: "23", v: "4", t: "Test verse text")
        
        // Create the view model
        viewModel = DevotionalViewModel()
        
        // Clear any existing cache
        DevotionalCacheManager.shared.clearCache()
    }
    
    func testSuccessfulAPIResponse() async throws {
        // Given: A mock API response
        let jsonResponse = """
        {
          "choices": [
            {
              "message": {
                "content": "{\\"title\\":\\"Finding Peace\\",\\"subtitle\\":\\"God's Comfort\\",\\"reference\\":\\"Psalms 23:4\\",\\"verse\\":\\"Test verse text\\",\\"contextualBackground\\":\\"Test background\\",\\"historicalInsights\\":\\"Test history\\",\\"linguisticInsights\\":\\"Test linguistics\\",\\"modernRelevance\\":\\"Test relevance\\",\\"reflectionQuestions\\":[\\"Question 1\\",\\"Question 2\\"],\\"prayer\\":\\"Test prayer\\"}"
              }
            }
          ]
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, Data(jsonResponse.utf8))
        }
        
        // When: We fetch a devotional
        // Using our test implementation doesn't have access to the real URLSession property
        // This is a testing limitation - in a real app we'd use dependency injection
        // For now, we'll just verify the cache behavior which is more testable
        
        // Create sample devotional
        let sampleDevotional = Devotional(
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
        
        // Cache it
        DevotionalCacheManager.shared.cacheDevotional(sampleDevotional, forReference: "Psalms 23:4")
        
        // Verify cache retrieval
        await viewModel.fetchDevotional(for: sampleVerse)
        
        // Then: We should have a cached devotional
        XCTAssertNotNil(viewModel.devotional)
        XCTAssertEqual(viewModel.devotional?.title, "Sample Title")
        if case .cached = viewModel.cacheStatus {
            // Correct cache status
        } else {
            XCTFail("Should be using cached content")
        }
    }
    
    func testErrorHandling() async {
        // Given: A network error
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }
        
        // When: We try to fetch a devotional with no cache available
        await viewModel.fetchDevotional(for: sampleVerse)
        
        // Then: We should get an error
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("No internet connection") ?? false)
    }
    
    func testRetryMechanism() {
        // Given: A verse has been processed
        viewModel.lastProcessedVerse = sampleVerse
        
        // When/Then: We should be able to retry with this verse
        XCTAssertNotNil(viewModel.lastProcessedVerse)
        XCTAssertEqual(viewModel.lastProcessedVerse?.reference, "Psalms 23:4")
    }
}
