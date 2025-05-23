//
//  CertificateValidationError.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation

/// Errors related to certificate validation
enum CertificateValidationError: Error, LocalizedError {
    case untrustedCertificate(domain: String)
    case certificateMismatch(domain: String, expected: String, received: String)
    case certificateValidationFailed(domain: String)
    
    var errorDescription: String? {
        switch self {
        case .untrustedCertificate(let domain):
            return "Untrusted server certificate for \(domain). This could indicate a security issue."
            
        case .certificateMismatch(let domain, _, _):
            return "Certificate mismatch for \(domain). This could indicate a security issue."
            
        case .certificateValidationFailed(let domain):
            return "Certificate validation failed for \(domain). This could indicate a security issue."
        }
    }
    
    var recoverySuggestion: String? {
        return "Please check your internet connection and try again. If the problem persists, the app may need to be updated."
    }
}
