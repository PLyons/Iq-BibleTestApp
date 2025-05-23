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
            
            // Replace the direct verse display with BibleVerseView component
            BibleVerseView(
                verse: verseVM.verse,
                isLoading: verseVM.isLoading
            )
            
            Spacer()

            if let devotional = devoVM.devotional {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(devotional.title)
                            .font(.title3).bold()
                        Text(devotional.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Reference: \(devotional.reference)")
                            .font(.subheadline).bold()
                        Text("Verse: \"\(devotional.verse)\"")
                            .font(.body).italic()
                        Text("## Background")
                            .font(.headline)
                        Text(devotional.contextualBackground)
                        Text("## Historical Insights")
                            .font(.headline)
                        Text(devotional.historicalInsights)
                        Text("## Linguistic Insights")
                            .font(.headline)
                        Text(devotional.linguisticInsights)
                        Text("## Modern Relevance")
                            .font(.headline)
                        Text(devotional.modernRelevance)
                        Text("## Reflection Questions")
                            .font(.headline)
                        ForEach(devotional.reflectionQuestions, id: \.self) { q in
                            Text("• \(q)")
                        }
                        Text("## Prayer")
                            .font(.headline)
                        Text(devotional.prayer).italic()
                    }
                    .padding(.horizontal)
                }
            } else if let error = devoVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

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
