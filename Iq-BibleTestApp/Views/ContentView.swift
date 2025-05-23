//
//  ContentView.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var verseVM = BibleVerseViewModel()
    @StateObject private var devoVM = DevotionalViewModel()
    @State private var isFirstAppear = true

    var body: some View {
        VStack {
            Spacer()
            
            // Using the BibleVerseView component
            BibleVerseView(
                verse: verseVM.verse,
                isLoading: verseVM.isLoading
            )
            
            Spacer()
            
            // Using the DevotionalView component
            DevotionalView(viewModel: devoVM)
            
            Button("Get Another Devotional") {
                refresh()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .onAppear {
            if isFirstAppear {
                isFirstAppear = false
                refresh()
            }
        }
    }

    private func refresh() {
        Task {
            print("ContentView: Starting refresh()")
            await verseVM.fetchRandomVerse()
            print("ContentView: Got verse? \(String(describing: verseVM.verse))")
            if let verse = verseVM.verse {
                await devoVM.fetchDevotional(for: verse)
                print("ContentView: Got devotional? \(String(describing: devoVM.devotional))")
            } else {
                print("ContentView: No verse to fetch devotional for.")
            }
        }
    }
}
