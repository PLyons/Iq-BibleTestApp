//
//  ContentView.swift
//  RandomBibleVerseDevotional
//
//  Created by Paul Lyons on 2025-05-21
//  Modified by ChatGPT on 2025-05-22
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @StateObject private var verseVM = BibleVerseViewModel()
    @StateObject private var devoVM = DevotionalViewModel()
    @State private var isFirstAppear = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Random Bible Devotional")
                    .font(.title)
                    .bold()
                    .padding(.top)

                if verseVM.isLoading || devoVM.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else {
                    BibleVerseView(verse: verseVM.verse, bookName: verseVM.bookName)
                    DevotionalView(devotional: devoVM.devotional)
                }

                if let error = verseVM.errorMessage ?? devoVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button(action: refresh) {
                    Text("Get Another Devotional")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(verseVM.isLoading || devoVM.isLoading)
                .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
        .onAppear {
            if isFirstAppear {
                isFirstAppear = false
                refresh()
            }
        }
    }

    func refresh() {
        Task {
            await verseVM.fetchRandomVerse()
            if let verse = verseVM.verse {
                await devoVM.generateDevotional(for: verse, bookName: verseVM.bookName)
            }
        }
    }
}

#Preview {
    ContentView()
}
