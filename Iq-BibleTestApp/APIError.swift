//
//  APIError.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation

/// API-related errors
enum APIError: Error, LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case invalidResponseFormat
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing or not configured. Please check the app configuration."
        case .invalidAPIKey:
            return "API key is invalid or has expired."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)"
        case .noData:
            return "No data received from the server."
        case .invalidResponseFormat:
            return "The server response format was invalid."
        }
    }
}
