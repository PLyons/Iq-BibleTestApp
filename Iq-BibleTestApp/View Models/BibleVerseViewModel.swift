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
    
    // Add secure session with certificate pinning
    private lazy var secureSession = CertificatePinningManager.shared.createPinnedSession()
    
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
        let apiKey = APIConfig.shared.bibleAPIKey ?? ""
        request.addValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")

        do {
            // Replace URLSession.shared with secureSession
            let (data, _) = try await secureSession.data(for: request)
            let debugString = String(data: data, encoding: .utf8) ?? "<no data>"
            print("BibleVerseViewModel: Received data \(debugString)")

            // Debug the JSON structure
            debugDecodeJSON(from: data)
            
            // The API returns a top-level array, not a wrapped object
            let verses = try JSONDecoder().decode([BibleVerse].self, from: data)
            if let v = verses.first {
                print("BibleVerseViewModel: Decoded verse \(v)")
                self.verse = v
            } else {
                print("BibleVerseViewModel: No verse in API response")
                errorMessage = "No verse found."
            }
        } catch let error as CertificateValidationError {
            // Handle certificate validation errors specifically
            print("BibleVerseViewModel: Certificate validation error: \(error.localizedDescription)")
            errorMessage = "Security error: \(error.localizedDescription)"
        } catch let error as URLError where error.code == .serverCertificateUntrusted {
            // Handle untrusted certificate errors from URLSession
            print("BibleVerseViewModel: Untrusted certificate error")
            errorMessage = "Security error: Untrusted server certificate. This may indicate a security issue."
        } catch let decodingError as DecodingError {
            // Provide more detailed debugging for JSON decoding errors
            print("BibleVerseViewModel: Decoding error \(decodingError)")
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch: expected \(type), context: \(context)")
            case .valueNotFound(let type, let context):
                print("Value not found: \(type), context: \(context)")
            case .keyNotFound(let key, let context):
                print("Key not found: \(key), context: \(context)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            errorMessage = "Error parsing verse data: \(decodingError.localizedDescription)"
        } catch {
            print("BibleVerseViewModel: Error fetching verse \(error.localizedDescription)")
            errorMessage = "Error fetching verse: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    // Debug function to help identify JSON structure issues
    private func debugDecodeJSON(from data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                print("JSON structure: \(json)")
                
                // Try manual decoding to see where it fails
                if let firstVerse = json.first {
                    let id = firstVerse["id"] as? String
                    let b = firstVerse["b"] as? String
                    let c = firstVerse["c"] as? String
                    let v = firstVerse["v"] as? String
                    let t = firstVerse["t"] as? String
                    
                    print("Manual decode - id: \(id ?? "nil"), b: \(b ?? "nil"), c: \(c ?? "nil"), v: \(v ?? "nil"), t: \(t ?? "nil")")
                }
            }
        } catch {
            print("Debug JSON decode error: \(error)")
        }
    }
}
