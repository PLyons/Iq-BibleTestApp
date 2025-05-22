//
//  BibleVerseViewModel.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

@MainActor
class BibleVerseViewModel: ObservableObject {
    @Published var verse: BibleVerse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchRandomVerse() async {
        isLoading = true
        errorMessage = nil
        let urlString = "https://iq-bible.p.rapidapi.com/GetRandomVerse?versionId=kjv"

        guard let url = URL(string: urlString) else {
            print("BibleVerseViewModel: Invalid URL")
            errorMessage = "Invalid Bible API URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        let apiKey = APIConfig.shared.iqBibleAPIKey ?? ""
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let debugString = String(data: data, encoding: .utf8) ?? "<no data>"
            print("BibleVerseViewModel: Received data \(debugString)")

            // The API returns a top-level array, not a wrapped object
            let verses = try JSONDecoder().decode([BibleVerse].self, from: data)
            if let v = verses.first {
                print("BibleVerseViewModel: Decoded verse \(v)")
                self.verse = v
            } else {
                print("BibleVerseViewModel: No verse in API response")
                errorMessage = "No verse found."
            }
        } catch {
            print("BibleVerseViewModel: Error fetching verse \(error.localizedDescription)")
            errorMessage = "Error fetching verse: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
