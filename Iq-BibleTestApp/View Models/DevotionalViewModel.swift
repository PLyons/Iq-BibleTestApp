//
//  DevotionalViewModel.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

@MainActor
class DevotionalViewModel: ObservableObject {
    @Published var devotional: Devotional?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cacheStatus: DevotionalCacheManager.CacheStatus = .fresh
    
    // Track last processed verse for retry functionality
    var lastProcessedVerse: BibleVerse?
    
    private let cacheManager = DevotionalCacheManager.shared
    
    // Add secure session with certificate pinning
    private lazy var secureSession: URLSession = {
        // Get base secure session
        let baseSession = CertificatePinningManager.shared.createPinnedSession()
        
        // Configure timeouts on the session
        let config = baseSession.configuration
        config.timeoutIntervalForRequest = 60.0  // 60 seconds timeout
        config.timeoutIntervalForResource = 60.0
        
        // Create new session with updated configuration
        return URLSession(configuration: config)
    }()

    func fetchDevotional(for verse: BibleVerse) async {
        isLoading = true
        errorMessage = nil
        lastProcessedVerse = verse  // Store for retry functionality
        cacheStatus = .fresh
        
        // Create reference string for caching
        let reference = "\(verse.bookName) \(verse.c):\(verse.v)"
        
        // Check if devotional is in cache
        if let cachedDevotional = cacheManager.getCachedDevotional(forReference: reference),
           let cacheTime = cacheManager.getCacheTime(forReference: reference) {
            // Use cached devotional
            self.devotional = cachedDevotional
            self.cacheStatus = .cached(cacheTime)
            self.isLoading = false
            print("DevotionalViewModel: Using cached devotional for \(reference)")
            return
        }

        let today = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        let prompt = PromptBuilder.buildPrompt(
            bookDisplay: verse.bookName,
            chapter: String(verse.c),
            verse: String(verse.v),
            verseText: verse.t,
            today: today
        )

        do {
            print("DevotionalViewModel: Sending request to Groq API...")
            let contentString = try await fetchGroqDevotionalResponse(prompt: prompt)
            print("DevotionalViewModel: Received content string: \(contentString.prefix(100))...")
            
            guard let data = contentString.data(using: .utf8) else {
                throw NSError(domain: "DevotionalViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Groq returned non-UTF8 data."])
            }
            
            // Try to parse as JSON and print any errors
            do {
                let devotional = try JSONDecoder().decode(Devotional.self, from: data)
                self.devotional = devotional
                print("DevotionalViewModel: Successfully decoded devotional")
                
                // Cache the devotional
                cacheManager.cacheDevotional(devotional, forReference: reference)
                
            } catch {
                print("DevotionalViewModel: JSON decoding error: \(error)")
                
                // Try to print the actual content for debugging
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("DevotionalViewModel: Raw JSON content: \(prettyString)")
                } else {
                    print("DevotionalViewModel: Raw content (not valid JSON): \(contentString)")
                }
                
                throw error
            }
        } catch let error as CertificateValidationError {
            // Handle certificate validation errors specifically
            print("DevotionalViewModel: Certificate validation error: \(error.localizedDescription)")
            self.errorMessage = "Security error: \(error.localizedDescription)"
        } catch let error as URLError {
            print("DevotionalViewModel: URLError: \(error.code.rawValue) - \(error.localizedDescription)")
            if error.code == .cancelled {
                self.errorMessage = "API request was cancelled. Please check your API key and network connection."
            } else if error.code == .timedOut {
                self.errorMessage = "API request timed out. The Groq server might be experiencing high load."
            } else if error.code == .serverCertificateUntrusted {
                self.errorMessage = "Security error: Untrusted server certificate."
            } else if error.code == .notConnectedToInternet {
                print("DevotionalViewModel: No internet connection, checking cache...")
                // Final attempt to use cache even if it's expired
                if let cachedDevotional = cacheManager.getCachedDevotional(forReference: reference),
                   let cacheTime = cacheManager.getCacheTime(forReference: reference) {
                    self.devotional = cachedDevotional
                    self.cacheStatus = .cached(cacheTime)
                    print("DevotionalViewModel: Using expired cached devotional while offline")
                } else {
                    self.errorMessage = "No internet connection and no cached devotional available."
                }
            } else {
                self.errorMessage = "Network error: \(error.localizedDescription)"
            }
        } catch {
            print("DevotionalViewModel: Error type: \(type(of: error))")
            print("DevotionalViewModel: Error generating devotional: \(error.localizedDescription)")
            self.errorMessage = "Failed to generate devotional: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func fetchGroqDevotionalResponse(prompt: String) async throws -> String {
        let apiKey = APIConfig.shared.groqAPIKey ?? ""
        guard !apiKey.isEmpty else {
            throw NSError(domain: "DevotionalViewModel", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Groq API key is missing."])
        }
        
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        let requestBody: [String: Any] = [
            "model": "llama3-70b-8192",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8,
            "max_tokens": 1000,
            "response_format": ["type": "json_object"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("DevotionalViewModel: Sending request to \(url.absoluteString)")
        
        // Use secure session with pinning and extended timeout
        let (data, response) = try await secureSession.data(for: request)
        
        // Print response details
        if let httpResponse = response as? HTTPURLResponse {
            print("DevotionalViewModel: Response status code: \(httpResponse.statusCode)")
        }

        struct GroqResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
            let error: ErrorInfo?
            
            struct ErrorInfo: Decodable {
                let message: String
                let type: String?
            }
        }

        // Try to decode response or print raw data for debugging
        do {
            let groq = try JSONDecoder().decode(GroqResponse.self, from: data)
            
            if let errorInfo = groq.error {
                throw NSError(domain: "GroqAPI", code: 4,
                              userInfo: [NSLocalizedDescriptionKey: "Groq API error: \(errorInfo.message)"])
            }
            
            guard let content = groq.choices.first?.message.content else {
                throw NSError(domain: "DevotionalViewModel", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "No content returned from Groq."])
            }
            return content
        } catch {
            if let responseString = String(data: data, encoding: .utf8) {
                print("DevotionalViewModel: Raw API response: \(responseString)")
            }
            throw error
        }
    }
    
    // Add a method to clear cache
    func clearCache() {
        cacheManager.clearCache()
    }
}
