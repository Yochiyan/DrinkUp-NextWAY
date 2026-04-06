//
//  File.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/01/31.
//

import Foundation
import Combine
final class AppSettings: ObservableObject {
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
        let saved = UserDefaults.standard.integer(forKey: "waterPrice")
        self.waterPrice = saved == 0 ? 0: saved
        
        let savedSize = UserDefaults.standard.integer(forKey: "vendingSize")
        self.vendingSize = savedSize == 0 ? 0 : savedSize
        
    }
    
    func reset() {
        // Reset in-memory values
        waterPrice = 0
        vendingSize = 0
        // Also clear persisted values for consistency
        UserDefaults.standard.removeObject(forKey: "waterPrice")
        UserDefaults.standard.removeObject(forKey: "vendingSize")
    }
    
}
