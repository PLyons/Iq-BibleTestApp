//
//  BibleVerseViewModel.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

@MainActor
class BibleVerseViewModel: ObservableObject {
    @Published var verse: BibleVerse?
    @Published var bookName: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    func fetchRandomVerse() async {
        isLoading = true
        defer { isLoading = false }
        let apiKey = APIConfig.iqBibleKey
        let urlString = "https://iq-bible.p.rapidapi.com/GetRandomVerse?versionId=kjv"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid Bible API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let verses = try JSONDecoder().decode([BibleVerse].self, from: data)
            if let verse = verses.first {
                self.verse = verse
                await fetchBookName(for: verse.b)
            } else {
                errorMessage = "No verse found in response."
            }
        } catch {
            errorMessage = "Failed to fetch verse: \(error.localizedDescription)"
        }
    }

    func fetchBookName(for bookId: String) async {
        let apiKey = APIConfig.iqBibleKey
        let urlString = "https://iq-bible.p.rapidapi.com/GetBookNameByBookId?bookId=\(bookId)&language=english"
        guard let url = URL(string: urlString) else {
            self.bookName = "Book \(bookId)"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let bookArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let name = bookArray.first?["n"] as? String {
                self.bookName = name
            } else {
                self.bookName = "Book \(bookId)"
            }
        } catch {
            self.bookName = "Book \(bookId)"
        }
    }
}
