//
//  DevotionalView.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/22/25.
//

import SwiftUI

struct DevotionalView: View {
    @ObservedObject var viewModel: DevotionalViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Generating devotional...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if let devotional = viewModel.devotional {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(devotional.title)
                            .font(.title)
                            .bold()
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
}

#if DEBUG
struct DevotionalView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DevotionalViewModel()
        DevotionalView(viewModel: viewModel)
    }
}
#endif
