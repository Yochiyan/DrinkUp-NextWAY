//
//  WaterIntakeIntent.swift
//  DrinkUp-NextWAY
//

import AppIntents
import Foundation

enum DrinkRecordStore {
    static let recordsKey = "records"
    static let bottlesKey = "bottles"

    @discardableResult
    static func append(amount: Int, date: Date = .now) -> Bool {
        guard amount > 0 else {
            return false
        }

        var records: [DrinkRecord] = []

        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decodedRecords = try? JSONDecoder().decode([DrinkRecord].self, from: data) {
            records = decodedRecords
        }

        records.append(DrinkRecord(date: date, amount: amount))

        guard let data = try? JSONEncoder().encode(records) else {
            return false
        }

        UserDefaults.standard.set(data, forKey: recordsKey)

        NotificationCenter.default.post(
            name: .drinkRecordsDidChange,
            object: nil
        )

        return true
    }

    static func registeredBottleAmount() -> Int? {
        guard let data = UserDefaults.standard.data(forKey: bottlesKey),
              let bottles = try? JSONDecoder().decode([Bottle].self, from: data),
              let bottle = bottles.first(where: { $0.size > 0 }) else {
            return nil
        }

        return bottle.size
    }
}

extension Notification.Name {
    static let drinkRecordsDidChange =
        Notification.Name("drinkRecordsDidChange")
}

enum WaterIntakeIntentError: Error, CustomLocalizedStringResourceConvertible {
    case noRegisteredBottle
    case invalidAmount
    case couldNotSave

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noRegisteredBottle:
            "DrinkUp!で水筒の容量を設定してから、もう一度お試しください。"

        case .invalidAmount:
            "1mL以上の水分量を指定してください。"

        case .couldNotSave:
            "水分摂取量を保存できませんでした。"
        }
    }
}

// MARK: - 登録済み水筒から記録

struct LogBottleWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "水筒から水分を記録"

    static let description = IntentDescription(
        "DrinkUp!に登録されている水筒の容量を水分摂取量として記録します。"
    )

    func perform() async throws -> some ProvidesDialog {
        guard let amount = await MainActor.run(
            body: DrinkRecordStore.registeredBottleAmount
        ) else {
            throw WaterIntakeIntentError.noRegisteredBottle
        }

        let didSave = await MainActor.run {
            DrinkRecordStore.append(amount: amount)
        }

        guard didSave else {
            throw WaterIntakeIntentError.couldNotSave
        }

        try? await HealthKitManager.shared.saveWater(
            amountML: Double(amount),
            date: .now
        )

        return .result(
            dialog: "\(amount)mLの水分を記録しました。"
        )
    }
}

// MARK: - 任意の水分量を記録

struct LogWaterAmountIntent: AppIntent {
    static let title: LocalizedStringResource = "水分量を記録"

    static let description = IntentDescription(
        "指定した水分量を記録します。"
    )

    @Parameter(
        title: "摂取量（mL）",
        requestValueDialog: "何mL飲みましたか？"
    )
    var amount: Int

    static var parameterSummary: some ParameterSummary {
        Summary("水分を \(\.$amount) mL 記録")
    }

    func perform() async throws -> some ProvidesDialog {
        guard amount > 0 else {
            throw WaterIntakeIntentError.invalidAmount
        }

        let didSave = await MainActor.run {
            DrinkRecordStore.append(amount: amount)
        }

        guard didSave else {
            throw WaterIntakeIntentError.couldNotSave
        }

        try? await HealthKitManager.shared.saveWater(
            amountML: Double(amount),
            date: .now
        )

        return .result(
            dialog: "\(amount)mLの水分を記録しました。"
        )
    }
}

// MARK: - Siri Shortcuts

struct DrinkUpAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogBottleWaterIntent(),
            phrases: [
                "水筒から飲んだよ \(.applicationName)",
                "水筒から飲んだ \(.applicationName)"
            ],
            shortTitle: "水筒から記録",
            systemImageName: "drop.fill"
        )

        AppShortcut(
            intent: LogWaterAmountIntent(),
            phrases: [
                "水分を記録して \(.applicationName)",
                "水分を記録 \(.applicationName)"
            ],
            shortTitle: "水分を記録",
            systemImageName: "drop.fill"
        )
    }
}
