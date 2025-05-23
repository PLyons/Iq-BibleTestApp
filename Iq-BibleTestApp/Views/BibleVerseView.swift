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

    var body: some View {
        if let verse = verse {
            VStack(spacing: 8) {
                // Use provided bookName if available, otherwise use verse.bookName
                let displayName = bookName ?? verse.bookName
                
                Text("**\(displayName) \(verse.c):\(verse.v)**")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("\"\(verse.t)\"")
                    .font(.title2)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
            }
        }
    }
}
