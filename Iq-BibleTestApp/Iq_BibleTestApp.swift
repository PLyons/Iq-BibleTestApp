//
//  Iq_BibleTestApp.swift
//  Iq-BibleTest
//
//  Created by Paul Lyons on 5/21/25.
//

import SwiftUI

@main
struct Iq_BibleTestApp: App {
    // Add an initializer to run the certificate extraction
    init() {
        #if DEBUG
        CertificateExtraction.extractCertificateHashes()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
