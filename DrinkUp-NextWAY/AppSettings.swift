//
//  File.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/01/31.
//

import Foundation
import Combine
final class AppSettings: ObservableObject {
    enum UnitSystem: String, CaseIterable, Codable {
        case ml
        case oz
    }

    @Published var unitSystem: UnitSystem {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: "unitSystem")
        }
    }
    
    @Published var waterPrice: Int {
        didSet {
            UserDefaults.standard.set(waterPrice, forKey: "waterPrice")
        }
    }
    
    @Published var vendingSize: Int {
        didSet {
            UserDefaults.standard.set(vendingSize, forKey: "vendingSize")
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: "unitSystem"),
           let savedUnit = UnitSystem(rawValue: raw) {
            self.unitSystem = savedUnit
        } else {
            self.unitSystem = .ml
        }
        
        let saved = UserDefaults.standard.integer(forKey: "waterPrice")
        self.waterPrice = saved == 0 ? 0: saved
        
        let savedSize = UserDefaults.standard.integer(forKey: "vendingSize")
        self.vendingSize = savedSize == 0 ? 0 : savedSize
        
    }
    
    func reset() {
        unitSystem = .ml
        // Reset in-memory values
        waterPrice = 0
        vendingSize = 0
        // Also clear persisted values for consistency
        UserDefaults.standard.removeObject(forKey: "waterPrice")
        UserDefaults.standard.removeObject(forKey: "vendingSize")
        UserDefaults.standard.removeObject(forKey: "unitSystem")
    }
    
    // MARK: - Unit Conversion Helpers (internal base: mL)
    func mlToOz(_ ml: Int) -> Double {
        return Double(ml) / 29.5735
    }

    func ozToMl(_ oz: Double) -> Int {
        return Int((oz * 29.5735).rounded())
    }
    
}
