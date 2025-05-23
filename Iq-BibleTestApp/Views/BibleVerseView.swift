//
//  BibleVerseView.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import SwiftUI

struct BibleVerseView: View {
    let verse: BibleVerse?
    let bookName: String?
    let isLoading: Bool
    
    // Added default parameters for easier use
    init(verse: BibleVerse? = nil, bookName: String? = nil, isLoading: Bool = false) {
        self.verse = verse
        self.bookName = bookName
        self.isLoading = isLoading
    }

    var body: some View {
        if isLoading {
            ProgressView("Loading verse...")
        } else if let verse = verse {
            VStack(spacing: 8) {
                // Use provided bookName if available, otherwise use verse.bookName
                let displayName = bookName ?? verse.bookName
                
                Text("\(displayName) \(verse.c):\(verse.v)")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 4)
                
                Text("\"\(verse.t)\"")
                    .font(.title2)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        } else {
            Text("No verse loaded.")
                .foregroundColor(.gray)
        }
    }
}
