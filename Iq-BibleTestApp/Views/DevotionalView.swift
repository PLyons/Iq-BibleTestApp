//
//  DevotionalView.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import SwiftUI

struct DevotionalView: View {
    @ObservedObject var viewModel: DevotionalViewModel
    @State private var isErrorAlertPresented = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(message: "Generating devotional insights...\nThis may take up to 30 seconds")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let error = viewModel.errorMessage {
                ErrorView(errorMessage: error) {
                    // Retry action
                    if let verse = viewModel.lastProcessedVerse {
                        Task {
                            await viewModel.fetchDevotional(for: verse)
                        }
                    } else {
                        isErrorAlertPresented = true
                    }
                }
                .padding()
                .alert(isPresented: $isErrorAlertPresented) {
                    Alert(
                        title: Text("Unable to Retry"),
                        message: Text("No verse information available for retry. Please get a new verse and try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            } else if let devotional = viewModel.devotional {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(devotional.title)
                                .font(.title)
                                .bold()
                            Spacer()
                            
                            // Add cache indicator
                            if case let .cached(date) = viewModel.cacheStatus {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .foregroundColor(.blue)
                                    Text("Cached")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemGray6))
                                )
                                .help("Cached on \(formatDate(date))")
                            }
                        }
                        
                        Text(devotional.subtitle)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(devotional.reference)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\"\(devotional.verse)\"")
                            .italic()
                            .padding(.vertical)

                        Group {
                            Text("Contextual Background")
                                .font(.headline)
                            Text(devotional.contextualBackground)
                                .padding(.bottom, 4)

                            Text("Historical Insights")
                                .font(.headline)
                            Text(devotional.historicalInsights)
                                .padding(.bottom, 4)

                            Text("Linguistic Insights")
                                .font(.headline)
                            Text(devotional.linguisticInsights)
                                .padding(.bottom, 4)

                            Text("Modern Relevance")
                                .font(.headline)
                            Text(devotional.modernRelevance)
                                .padding(.bottom, 4)

                            Text("Reflection Questions")
                                .font(.headline)
                            ForEach(devotional.reflectionQuestions, id: \.self) { q in
                                Text("• \(q)")
                            }

                            Text("Prayer")
                                .font(.headline)
                            Text(devotional.prayer)
                                .italic()
                                .padding(.top, 6)
                        }
                    }
                    .padding()
                }
            } else {
                Text("No devotional loaded.")
            }
        }
        .navigationTitle("Devotional")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
