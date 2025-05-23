//
//  SecureConfigManager.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation
import CryptoKit

/// A secure manager for accessing app configuration including API keys
class SecureConfigManager {
    
    /// Shared instance for app-wide use
    static let shared = SecureConfigManager()
    
    /// Name of the property list file containing the API keys
    private let configFileName = "ApiConfig"
    
    /// Cache for decrypted API keys to avoid repeated decryption
    private var decryptedKeys: [String: String] = [:]
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - API Key Access
    
    /// Retrieves the Groq API key with security measures
    /// - Returns: The API key or nil if not configured
    func getGroqAPIKey() -> String? {
        return getSecureValue(forKey: "GroqAPIKey")
    }
    
    /// Retrieves the Bible API key with security measures
    /// - Returns: The API key or nil if not configured
    func getBibleAPIKey() -> String? {
        return getSecureValue(forKey: "BibleAPIKey")
    }
    
    /// Checks if Groq API key is properly configured
    /// - Returns: Boolean indicating if the key is valid
    func hasValidGroqAPIKey() -> Bool {
        guard let key = getGroqAPIKey() else { return false }
        return !key.isEmpty
    }
    
    /// Checks if Bible API key is properly configured
    /// - Returns: Boolean indicating if the key is valid
    func hasValidBibleAPIKey() -> Bool {
        guard let key = getBibleAPIKey() else { return false }
        return !key.isEmpty
    }
    
    // MARK: - Private Methods
    
    /// Retrieves a value from the configuration with security measures
    /// - Parameter key: The key to retrieve from the configuration
    /// - Returns: The decrypted/deobfuscated value or nil if not found
    private func getSecureValue(forKey key: String) -> String? {
        // Check cache first
        if let cachedValue = decryptedKeys[key] {
            return cachedValue
        }
        
        // Load from plist
        guard let obfuscatedValue = getValueFromPlist(key: key) else {
            print("Warning: No value found for key \(key) in \(configFileName).plist")
            return nil
        }
        
        // Deobfuscate the value
        let deobfuscatedValue = deobfuscate(obfuscatedValue)
        
        // Cache the result
        decryptedKeys[key] = deobfuscatedValue
        
        return deobfuscatedValue
    }
    
    /// Loads a raw value from the property list file
    /// - Parameter key: The key to load
    /// - Returns: The raw value or nil if not found
    private func getValueFromPlist(key: String) -> String? {
        guard let path = Bundle.main.path(forResource: configFileName, ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = plistDict[key] as? String else {
            return nil
        }
        
        return value
    }
    
    /// Deobfuscates a value using app-specific techniques
    /// - Parameter value: The obfuscated value
    /// - Returns: The deobfuscated original value
    private func deobfuscate(_ value: String) -> String {
        // Simple deobfuscation - for demonstration
        // In a real app, use a more complex algorithm
        
        // This simple approach reverses the string and removes a known suffix
        let reversed = String(value.reversed())
        let cleanValue = reversed.replacingOccurrences(of: "_SECURE_", with: "")
        
        return cleanValue
    }
}
