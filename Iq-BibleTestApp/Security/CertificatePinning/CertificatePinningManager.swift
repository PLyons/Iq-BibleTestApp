//
//  CertificatePinningManager.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation

/// Manager for handling certificate pinning and SSL certificate validation
class CertificatePinningManager: NSObject {
    
    /// Shared instance for app-wide use
    static let shared = CertificatePinningManager()
    
    /// Dictionary mapping server domains to their expected public key hashes
    private let serverTrustDict: [String: [String]] = [
        // RapidAPI/Bible API certificate
        "iq-bible.p.rapidapi.com": [
            // You'll replace this with the actual hash from Terminal
            "imX31PK2ta8G7CY/GUYdW+U2dhWt/g8ynTWd9d+tnOs="
        ],
        // Groq API certificate
        "api.groq.com": [
            // You'll replace this with the actual hash from Terminal
            "xCO7RP5QxGzjtGdK9yEXhncp+UqajCBIirVzml0rQ/M="
        ]
    ]
    
    /// Private initializer to enforce singleton pattern
    private override init() {
        super.init()
    }
    
    /// Creates a URLSession configured with certificate pinning
    /// - Returns: A URLSession instance with certificate validation
    func createPinnedSession() -> URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    /// Validates a server trust against pinned certificates
    /// - Parameters:
    ///   - serverTrust: The server trust to validate
    ///   - domain: The domain being accessed
    /// - Returns: True if validation succeeds, false otherwise
    func validateServerTrust(_ serverTrust: SecTrust, forDomain domain: String) -> Bool {
        // Get the pinned hashes for this domain
        guard let pinnedPublicKeyHashes = serverTrustDict[domain] else {
            print("Certificate pinning not configured for domain: \(domain)")
            return false
        }
        
        // Extract the server's public key
        guard let serverPublicKey = SecTrustCopyKey(serverTrust) else {
            print("Failed to get public key from server certificate")
            return false
        }
        
        // Convert the server's public key to data
        var error: Unmanaged<CFError>?
        guard let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, &error) as Data? else {
            print("Failed to convert server public key to data: \(error.debugDescription)")
            return false
        }
        
        // Hash the server's public key
        let serverPublicKeyHash = sha256(data: serverPublicKeyData).base64EncodedString()
        
        // Check if the server's hash matches any of our pinned hashes
        if pinnedPublicKeyHashes.contains(serverPublicKeyHash) {
            return true
        }
        
        // Log the actual hash for debugging purposes
        print("Certificate pinning failed for domain: \(domain)")
        print("Server public key hash: \(serverPublicKeyHash)")
        print("Expected one of: \(pinnedPublicKeyHashes)")
        
        return false
    }
    
    /// Computes the SHA-256 hash of data
    /// - Parameter data: The data to hash
    /// - Returns: The hash as Data
    private func sha256(data: Data) -> Data {
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return Data(hash)
    }
}

// MARK: - URLSessionDelegate Extension
extension CertificatePinningManager: URLSessionDelegate {
    
    /// Handles SSL validation for URLSession
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let domain = challenge.protectionSpace.host as String? else {
            // Fall back to default handling for other types of challenges
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Validate against our pinned certificates
        if validateServerTrust(serverTrust, forDomain: domain) {
            // Validation succeeded, proceed with the connection
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Validation failed, cancel the connection
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
