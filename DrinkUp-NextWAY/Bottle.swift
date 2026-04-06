//
//  Bottle.swift
//  How many drink water?
//
//  Created by よっちゃん on 2025/09/18.
//

import Foundation


struct Bottle: Identifiable, Codable, Equatable {
    var id = UUID()
    var size: Int
}
