// APIConfig.swift
// Iq-BibleTestApp
// Created by Paul Lyons on 5/22/25.

import Foundation

/// Configuration class for managing API keys
class APIConfig {
    /// Shared instance for app-wide use
    static let shared = APIConfig()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Retrieves the Groq API key securely
    var groqAPIKey: String? {
        return SecureConfigManager.shared.getGroqAPIKey()
    }
    
    /// Retrieves the Bible API key securely
    var bibleAPIKey: String? {
        return SecureConfigManager.shared.getBibleAPIKey()
    }
    
    /// Checks if the Groq API key is properly configured
    var hasValidGroqAPIKey: Bool {
        return SecureConfigManager.shared.hasValidGroqAPIKey()
    }
    
    /// Checks if the Bible API key is properly configured
    var hasValidBibleAPIKey: Bool {
        return SecureConfigManager.shared.hasValidBibleAPIKey()
    }
}
