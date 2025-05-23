//
//  DevotionalCacheManager.swift
//  Iq-BibleTestApp
//
//  Created by Paul Lyons on 5/23/25.
//

import Foundation

class DevotionalCacheManager {
    static let shared = DevotionalCacheManager()
    
    private let defaults = UserDefaults.standard
    private let cacheKey = "cached_devotionals"
    private let cacheTimeKey = "cached_devotionals_timestamps"
    private let cacheDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    private init() {}
    
    // Save a devotional to cache
    func cacheDevotional(_ devotional: Devotional, forReference reference: String) {
        // Create encoder
        let encoder = JSONEncoder()
        
        // Get existing cache or create new one
        var cachedDevotionals = getCachedDevotionals()
        var cacheTimes = getCacheTimes()
        
        // Cache the devotional
        do {
            let devotionalData = try encoder.encode(devotional)
            cachedDevotionals[reference] = devotionalData
            cacheTimes[reference] = Date().timeIntervalSince1970
            
            // Save updated cache
            defaults.set(cachedDevotionals, forKey: cacheKey)
            defaults.set(cacheTimes, forKey: cacheTimeKey)
            print("DevotionalCache: Successfully cached devotional for \(reference)")
        } catch {
            print("DevotionalCache: Error caching devotional - \(error.localizedDescription)")
        }
    }
    
    // Get a cached devotional if available
    func getCachedDevotional(forReference reference: String) -> Devotional? {
        let cachedDevotionals = getCachedDevotionals()
        let cacheTimes = getCacheTimes()
        
        guard let devotionalData = cachedDevotionals[reference],
              let cachedTime = cacheTimes[reference] else {
            print("DevotionalCache: No cache found for \(reference)")
            return nil
        }
        
        // Check if cache is expired
        let currentTime = Date().timeIntervalSince1970
        if currentTime - cachedTime > cacheDuration {
            print("DevotionalCache: Cache expired for \(reference)")
            removeFromCache(reference: reference)
            return nil
        }
        
        // Decode and return devotional
        do {
            let decoder = JSONDecoder()
            let devotional = try decoder.decode(Devotional.self, from: devotionalData)
            print("DevotionalCache: Successfully retrieved cached devotional for \(reference)")
            return devotional
        } catch {
            print("DevotionalCache: Error decoding cached devotional - \(error.localizedDescription)")
            return nil
        }
    }
    
    // Get cache timestamp for a reference
    func getCacheTime(forReference reference: String) -> Date? {
        let cacheTimes = getCacheTimes()
        guard let timestamp = cacheTimes[reference] else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
    
    // Remove a specific devotional from cache
    func removeFromCache(reference: String) {
        var cachedDevotionals = getCachedDevotionals()
        var cacheTimes = getCacheTimes()
        
        cachedDevotionals.removeValue(forKey: reference)
        cacheTimes.removeValue(forKey: reference)
        
        defaults.set(cachedDevotionals, forKey: cacheKey)
        defaults.set(cacheTimes, forKey: cacheTimeKey)
    }
    
    // Clear entire cache
    func clearCache() {
        defaults.removeObject(forKey: cacheKey)
        defaults.removeObject(forKey: cacheTimeKey)
        print("DevotionalCache: Cache cleared")
    }
    
    // Helper to retrieve cached devotionals dictionary
    private func getCachedDevotionals() -> [String: Data] {
        return defaults.object(forKey: cacheKey) as? [String: Data] ?? [:]
    }
    
    // Helper to retrieve cache timestamps
    private func getCacheTimes() -> [String: TimeInterval] {
        return defaults.object(forKey: cacheTimeKey) as? [String: TimeInterval] ?? [:]
    }
    
    // Get cache status (freshly loaded vs cached)
    enum CacheStatus {
        case fresh
        case cached(Date)
    }
}
