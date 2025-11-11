//
//  StartupProfiler.swift
//  lewens
//
//  Utility class for measuring app startup performance

import Foundation

class StartupProfiler {
    static let shared = StartupProfiler()
    
    private let startTime = Date()
    private var milestones: [(String, TimeInterval)] = []
    
    func recordMilestone(_ name: String) {
        let elapsed = Date().timeIntervalSince(startTime)
        milestones.append((name, elapsed))
        
        // Calculate delta from previous milestone
        let delta: TimeInterval
        if milestones.count > 1 {
            delta = elapsed - milestones[milestones.count - 2].1
        } else {
            delta = elapsed
        }
        
        print("[StartupProfiler] \(name): \(String(format: "%.3f", elapsed))s (Δ +\(String(format: "%.3f", delta))s)")
    }
    
    func printSummary() {
        print("\n" + "═".repeated(50))
        print("🚀 App Startup Performance Summary")
        print("═".repeated(50))
        
        for (name, time) in milestones {
            let delta: TimeInterval
            if let index = milestones.firstIndex(where: { $0.0 == name }), index > 0 {
                delta = time - milestones[index - 1].1
            } else {
                delta = time
            }
            
            print("✓ \(name)")
            print("  ├─ Total: \(String(format: "%.3f", time))s")
            print("  └─ Delta: +\(String(format: "%.3f", delta))s")
        }
        
        let totalTime = Date().timeIntervalSince(startTime)
        print("─".repeated(50))
        print("📊 Total startup time: \(String(format: "%.3f", totalTime))s")
        
        // Performance analysis
        if totalTime > 2.0 {
            print("\n⚠️  Startup time > 2s detected")
            print("   Possible causes:")
            print("   • Debug compilation overhead")
            print("   • Network requests during init")
            print("   • Bundle loading delays")
            print("   • Cryptography initialization (AppAuth)")
            print("\n   💡 Tip: Test in Release mode for accurate measurement")
        }
        
        print("═".repeated(50) + "\n")
    }
}

private extension String {
    func repeated(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}
