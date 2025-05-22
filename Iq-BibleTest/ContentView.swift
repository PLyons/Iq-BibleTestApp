//
//  ContentView.swift
//  RandomBibleVerseDevotional
//
//  Created by Paul Lyons on 2025-05-21
//  Modified by ChatGPT on 2025-05-22
//

import SwiftUI

struct BibleVerse: Decodable, Identifiable {
    let id: String
    let b: String // Book ID
    let c: String // Chapter
    let v: String // Verse
    let t: String // Text
}

struct ContentView: View {
    @State private var verse: BibleVerse?
    @State private var bookName: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var devotional: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Random Bible Devotional")
                    .font(.title)
                    .bold()
                    .padding(.top)

                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let verse = verse {
                    VStack(spacing: 8) {
                        if let bookName = bookName {
                            Text("**\(bookName) \(verse.c):\(verse.v)**")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        Text("\"\(verse.t)\"")
                            .font(.title2)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }
                }

                if let devotional = devotional {
                    Divider()
                    Text(devotional)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: fetchRandomVerseAndDevotional) {
                    Text("Get Another Devotional")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
        .onAppear(perform: fetchRandomVerseAndDevotional)
    }

    func fetchRandomVerseAndDevotional() {
        verse = nil
        bookName = nil
        devotional = nil
        errorMessage = nil
        isLoading = true

        // Step 1: Fetch a random verse from IQ Bible API
        let verseUrlString = "https://iq-bible.p.rapidapi.com/GetRandomVerse?versionId=kjv"
        guard let url = URL(string: verseUrlString) else {
            errorMessage = "Invalid Bible API URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Your IQ Bible API Key:
        request.setValue("e7f0b2bbb3mshece2e7457cf57aep1463abjsnd4331173e3c9", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                }
                return
            }
            // Debug: Print raw response
            // print("Raw response:", String(data: data, encoding: .utf8) ?? "nil")
            do {
                let verses = try JSONDecoder().decode([BibleVerse].self, from: data)
                if let verse = verses.first {
                    DispatchQueue.main.async {
                        self.verse = verse
                        fetchBookName(for: verse.b) // Get the book name
                        // Step 2: Generate devotional using Groq
                        generateDevotional(for: verse)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No verse found in response."
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse Bible API: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    func fetchBookName(for bookId: String) {
        let urlString = "https://iq-bible.p.rapidapi.com/GetBookNameByBookId?bookId=\(bookId)&language=english"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.bookName = "Book \(bookId)"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("e7f0b2bbb3mshece2e7457cf57aep1463abjsnd4331173e3c9", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let bookArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
               let name = bookArray.first?["n"] as? String {
                DispatchQueue.main.async {
                    self.bookName = name
                }
            } else {
                DispatchQueue.main.async {
                    self.bookName = "Book \(bookId)"
                }
            }
        }.resume()
    }

    func generateDevotional(for verse: BibleVerse) {
        // Step 3: Format the prompt as discussed
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

        let groqApiKey = "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" // Your Groq API Key
        let endpoint = "https://api.groq.com/openai/v1/chat/completions"
        let model = "llama3-70b-8192"

        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid Groq API URL."
                self.isLoading = false
            }
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
        request.setValue("Bearer \(groqApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Groq API error: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data from Groq."
                }
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.devotional = content.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse Groq API response."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing Groq response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
