//
//  DevotionalView.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/22/25.
//

import SwiftUI

struct DevotionalView: View {
    let devotional: String?

    var body: some View {
        if let devotional = devotional {
            Divider()
            Text(devotional)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}
