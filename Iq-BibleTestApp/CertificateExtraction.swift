//
//  CertificateExtraction.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation
import SwiftUI

#if DEBUG
/// Provides certificate extraction capabilities for the app
struct CertificateExtraction {
    /// Extracts certificate hashes for debugging purposes
    static func extractCertificateHashes() {
        // Run in background to avoid blocking the main thread
        DispatchQueue.global(qos: .background).async {
            ExtractCertificateHashes.extractAllCertificates()
        }
    }
}
#endif
