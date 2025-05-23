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

    func fetchDevotional(for verse: BibleVerse) async {
        isLoading = true
        errorMessage = nil

        // Validate API key first
        guard let apiKey = APIConfig.shared.groqAPIKey, !apiKey.isEmpty else {
            errorMessage = "API key is missing or not configured. Please check the app configuration."
            isLoading = false
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
            let contentString = try await fetchGroqDevotionalResponse(prompt: prompt)
            guard let data = contentString.data(using: .utf8) else {
                throw NSError(domain: "DevotionalViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Groq returned non-UTF8 data."])
            }
            let devotional = try JSONDecoder().decode(Devotional.self, from: data)
            self.devotional = devotional
        } catch {
            self.errorMessage = "Failed to generate devotional: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func fetchGroqDevotionalResponse(prompt: String) async throws -> String {
        guard let apiKey = APIConfig.shared.groqAPIKey, !apiKey.isEmpty else {
            throw NSError(domain: "DevotionalViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "Missing Groq API key."])
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
            "max_tokens": 1000
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for authentication errors
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                throw NSError(domain: "DevotionalViewModel", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid API key or authentication failed."])
            } else if httpResponse.statusCode != 200 {
                throw NSError(domain: "DevotionalViewModel", code: 5, userInfo: [NSLocalizedDescriptionKey: "Server returned error code \(httpResponse.statusCode)."])
            }
        }

        struct GroqResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let groq = try JSONDecoder().decode(GroqResponse.self, from: data)
        guard let content = groq.choices.first?.message.content else {
            throw NSError(domain: "DevotionalViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "No content returned from Groq."])
        }
        return content
    }
}
