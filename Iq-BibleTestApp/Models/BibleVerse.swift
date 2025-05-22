//
//  BibleVerse.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import Foundation

struct BibleVerse: Decodable, Identifiable {
    let id: String
    let b: String //Book ID
    let c: String //Chapter
    let v: String //Verse
    let t: String //Text
}
