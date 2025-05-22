//
//  DevotionalViewModel.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

@MainActor
class DevotionalViewModel: ObservableObject {
    @Published var devotional: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generateDevotional(for verse: BibleVerse, bookName: String?) async {
        isLoading = true
        defer { isLoading = false }
        let apiKey = APIConfig.groqKey
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let today = dateFormatter.string(from: Date())

        let bookDisplay = bookName ?? "Book \(verse.b)"
        let prompt = """
        Create a daily devotional for a Bible app based on the following Bible verse from the King James Version (KJV):

        \(bookDisplay) \(verse.c):\(verse.v) - "\(verse.t)"

        Date: \(today)

        Devotional Guidelines:

        1. Title as a Heading: Use # for the title at the very top.
        2. Subtitle (Date, Passage Reference, and Context Summary): Follow with a **bolded summary** line immediately below the title to provide quick context.
        3. Verse Block Formatting: Place the verse text directly beneath the title and summary in a Markdown blockquote (using >) for emphasis, like this:
            > "\(verse.t)"
            > **\(bookDisplay) \(verse.c):\(verse.v)**
        4. Devotional Content Formatting:
            - Contextual Background: Begin with the verse's background, add explicit section headers with ##.
            - Historical and Cultural Insights: Provide context, customs, events, or traditions to enrich understanding.
            - Linguistic and Translational Insights: Include key Hebrew or Greek words with meanings if relevant.
        5. Modern Relevance: Guide the reader to relate the passage to today.
        6. Personal Reflection and Application:
            - Include reflective questions at the end, formatted as a Markdown list.
        7. Final Meditation: Close with a short meditation or prayerful reflection, formatted in italics.
        """

        let endpoint = "https://api.groq.com/openai/v1/chat/completions"
        let model = "llama3-70b-8192"

        guard let url = URL(string: endpoint) else {
            self.errorMessage = "Invalid Groq API URL."
            return
        }

        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1000,
            "temperature": 0.8
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                self.devotional = content.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                self.errorMessage = "Failed to parse Groq API response."
            }
        } catch {
            self.errorMessage = "Error generating devotional: \(error.localizedDescription)"
        }
    }
}
