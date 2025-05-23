//
//  PublicKeyHashExtractor.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

#if DEBUG
import Foundation

/// A utility class to extract and display public key hashes from SSL certificates
class PublicKeyHashExtractor {
    
    /// Extracts and prints the public key hash for a given server
    /// - Parameter serverName: The server domain name to check
    static func printPublicKeyHashForServer(_ serverName: String) {
        let url = URL(string: "https://\(serverName)")!
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { _, response, error in
            if let error = error {
                print("Error connecting to \(serverName): \(error.localizedDescription)")
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("Invalid response from \(serverName)")
                return
            }
            
            print("Connected to \(serverName) with status code: \(response.statusCode)")
            print("To extract the public key hash, run this Terminal command:")
            print("")
            print("openssl s_client -servername \(serverName) -connect \(serverName):443 </dev/null | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64")
            print("")
        }
        
        task.resume()
    }
}
#endif
