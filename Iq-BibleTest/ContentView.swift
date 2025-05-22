//
//  ContentView.swift
//  RandomBibleVerseDemo
//
//  Created by [Your Name] on 2025-05-21
//  Modified by ChatGPT on 2025-05-21
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
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var bookName: String?

    var body: some View {
        VStack(spacing: 24) {
            Text("Random Bible Verse")
                .font(.title)
                .bold()
                .padding(.top)

            if isLoading {
                ProgressView()
            } else if let verse = verse {
                VStack(spacing: 8) {
                    Text(verse.t)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    if let bookName = bookName {
                        Text("\(bookName) \(verse.c):\(verse.v)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Loading book name...")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: fetchRandomVerse) {
                Text("Get Another Verse")
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
        .onAppear(perform: fetchRandomVerse)
        .padding()
    }

    func fetchRandomVerse() {
        verse = nil
        bookName = nil
        errorMessage = nil
        isLoading = true

        let urlString = "https://iq-bible.p.rapidapi.com/GetRandomVerse?versionId=kjv"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
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

            do {
                let verses = try JSONDecoder().decode([BibleVerse].self, from: data)
                if let verse = verses.first {
                    DispatchQueue.main.async {
                        self.verse = verse
                        self.fetchBookName(for: verse.b)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No verse found in response."
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse response: \(error.localizedDescription)"
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
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("e7f0b2bbb3mshece2e7457cf57aep1463abjsnd4331173e3c9", forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                DispatchQueue.main.async {
                    self.bookName = "Book \(bookId)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.bookName = "Book \(bookId)"
                }
                return
            }
            do {
                if let bookArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let name = bookArray.first?["n"] as? String {
                    DispatchQueue.main.async {
                        self.bookName = name
                    }
                } else if let bookArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let name = bookArray["n"] as? String {
                    DispatchQueue.main.async {
                        self.bookName = name
                    }
                } else {
                    DispatchQueue.main.async {
                        self.bookName = "Book \(bookId)"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.bookName = "Book \(bookId)"
                }
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}
