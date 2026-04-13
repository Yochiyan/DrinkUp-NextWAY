//
//  HealthKitManager.swift
//  DrinkUp!
//
//  Created by よっちゃん on 2025/12/28.
//

import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    // HealthKitが使えるか確認
    func isAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    // 権限リクエスト
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let waterType = HKObjectType.quantityType(
            forIdentifier: .dietaryWater
        ) else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(
            toShare: [waterType],
            read: [waterType]
        ) { success, _ in
            completion(success)
        }
    }
    
    // 水分摂取量を書き込む
    func saveWater(amountML: Double, date: Date) async throws {
        guard let waterType = HKQuantityType.quantityType(
            forIdentifier: .dietaryWater
        ) else { return }

        let quantity = HKQuantity(
            unit: .literUnit(with: .milli),
            doubleValue: amountML
        )

        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )

        try await healthStore.save(sample)
    }
    }
extension HealthKitManager {

    func syncAll(records: [DrinkRecord]) async throws {
        for record in records {
            try await saveWater(
                amountML: Double(record.amount),
                date: record.date
            )
        }
    }
}
