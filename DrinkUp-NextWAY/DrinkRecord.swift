//
//  DrinkRecord.swift
//  How many drink water?
//
//  Created by よっちゃん on 2025/09/18.
//

import Foundation


struct DrinkRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var amount: Int
}
