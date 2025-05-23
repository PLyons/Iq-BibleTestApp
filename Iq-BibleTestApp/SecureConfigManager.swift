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
    
    /// Retrieves the OpenAI API key with security measures
    /// - Returns: The API key or nil if not configured
    func getOpenAIAPIKey() -> String? {
        return getSecureValue(forKey: "OpenAIAPIKey")
    }
    
    /// Retrieves the Bible API key with security measures
    /// - Returns: The API key or nil if not configured
    func getBibleAPIKey() -> String? {
        return getSecureValue(forKey: "BibleAPIKey")
    }
    
    /// Checks if OpenAI API key is properly configured
    /// - Returns: Boolean indicating if the key is valid
    func hasValidOpenAIAPIKey() -> Bool {
        guard let key = getOpenAIAPIKey() else { return false }
        // OpenAI keys typically start with "sk-"
        return !key.isEmpty && key.starts(with: "sk-")
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
    
    /// Creates a device-specific factor for additional security
    /// - Returns: A string derived from device properties
    private func getDeviceSpecificFactor() -> String {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let deviceName = UIDevice.current.name
        let systemVersion = UIDevice.current.systemVersion
        
        let combined = bundleID + deviceName + systemVersion + "IqBibleAppSalt"
        let data = Data(combined.utf8)
        let hash = SHA256.hash(data: data)
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
