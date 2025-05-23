//
//  BibleVerse.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

// MARK: - BibleVerse (Individual Verse)
struct BibleVerse: Codable, Identifiable, Equatable {
    var id: String { "\(b)-\(c)-\(v)" }
    let b: String       // Book *name* or ordinal as string
    let c: String       // Chapter as string (changed from Int to match API response)
    let v: String       // Verse as string (changed from Int to match API response)
    let t: String       // Text of the verse

    // If your API sometimes returns book as an ordinal (number as string), map it:
    static let bookNames = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel",
        "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther",
        "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
        "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
        "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans",
        "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians",
        "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews",
        "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"
    ]

    var bookName: String {
        // Try to parse 'b' as integer (ordinal), fallback to string
        if let ordinal = Int(b), ordinal > 0, ordinal <= BibleVerse.bookNames.count {
            return BibleVerse.bookNames[ordinal - 1]
        }
        return b
    }
    
    // Convenience properties to get integer values when needed
    var chapterNumber: Int {
        return Int(c) ?? 0
    }
    
    var verseNumber: Int {
        return Int(v) ?? 0
    }
}
