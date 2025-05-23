//
//  ExtractCertificateHashes.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

#if DEBUG
import Foundation
import Security

/// Command-line tool to extract public key hashes from SSL certificates
class ExtractCertificateHashes {
    
    static func extract(from domain: String) {
        print("Extracting certificate information for \(domain)...")
        
        guard let url = URL(string: "https://\(domain)") else {
            print("Invalid domain: \(domain)")
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { _, response, error in
            defer {
                semaphore.signal()
            }
            
            if let error = error {
                print("Error connecting to \(domain): \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response from \(domain)")
                return
            }
            
            print("Connected to \(domain) with status code: \(response.statusCode)")
            
            // Display certificate extraction instructions
            print("=== Certificate Extraction Instructions for \(domain) ===")
            print("1. Open Terminal")
            print("2. Run the following command:")
            print("")
            print("   openssl s_client -servername \(domain) -connect \(domain):443 </dev/null | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64")
            print("")
            print("3. Copy the resulting hash (a Base64 string)")
            print("4. Update the serverTrustDict in CertificatePinningManager.swift for '\(domain)'")
            print("===================================================")
        }
        
        task.resume()
        semaphore.wait()
    }
    
    /// Run this function to extract certificates for all relevant domains
    static func extractAllCertificates() {
        print("\n=== CERTIFICATE HASH EXTRACTION TOOL ===\n")
        
        extract(from: "iq-bible.p.rapidapi.com")
        extract(from: "api.groq.com")
        
        print("\nDone extracting certificate information.")
        print("\nIMPORTANT: After obtaining the certificate hashes, update the")
        print("serverTrustDict in CertificatePinningManager.swift with the actual hashes.")
        print("\n=======================================\n")
    }
}
#endif
