//
//  NotificationManager.swift
//  DrinkUp-NextWAY
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined {
        didSet {
            UserDefaults.standard.set(
                authorizationStatus.rawValue,
                forKey: Keys.authorizationStatus
            )
        }
    }
    @Published var isMorningNotificationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMorningNotificationEnabled, forKey: Keys.isMorningNotificationEnabled)
        }
    }
    @Published var isInactivityReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(
                isInactivityReminderEnabled,
                forKey: Keys.isInactivityReminderEnabled
            )
        }
    }
    @Published var morningNotificationTime: Date {
        didSet {
            UserDefaults.standard.set(
                morningNotificationTime.timeIntervalSinceReferenceDate,
                forKey: Keys.morningNotificationTime
            )
        }
    }

    private enum Keys {
        static let isMorningNotificationEnabled = "isMorningNotificationEnabled"
        static let isInactivityReminderEnabled = "isInactivityReminderEnabled"
        static let morningNotificationTime = "morningNotificationTime"
        static let authorizationStatus = "notificationAuthorizationStatus"
        static let inactivityReminderDate = "inactivityReminderDate"
        static let inactivityReminderCount = "inactivityReminderCount"
    }

    private enum Identifier {
        static let morning = "drinkup.morning"
        static let inactivityPrefix = "drinkup.inactivity"
    }

    private let center = UNUserNotificationCenter.current()
    private let calendar = Calendar.current

    private init() {
        isMorningNotificationEnabled = UserDefaults.standard.object(
            forKey: Keys.isMorningNotificationEnabled
        ) as? Bool ?? true
        isInactivityReminderEnabled = UserDefaults.standard.object(
            forKey: Keys.isInactivityReminderEnabled
        ) as? Bool ?? true

        let defaultTime = calendar.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: .now
        ) ?? .now
        let storedTime = UserDefaults.standard.double(forKey: Keys.morningNotificationTime)
        morningNotificationTime = storedTime == 0
            ? defaultTime
            : Date(timeIntervalSinceReferenceDate: storedTime)
    }

    func refreshAuthorizationStatus() async {
        authorizationStatus = await center.notificationSettings().authorizationStatus
    }

    func requestAuthorization() async {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            // The settings value below reflects whether notifications are available.
        }

        await refreshAuthorizationStatus()
        await scheduleMorningNotificationIfNeeded()
    }

    func scheduleMorningNotificationIfNeeded() async {
        center.removePendingNotificationRequests(withIdentifiers: [Identifier.morning])

        guard isMorningNotificationEnabled, isAuthorized else {
            return
        }

        let components = calendar.dateComponents(
            [.hour, .minute],
            from: morningNotificationTime
        )
        let content = UNMutableNotificationContent()
        content.title = "おはよー！"
        content.body = "水筒に好きな飲み物を入れて今日を始めよう！"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: Identifier.morning,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelMorningNotification() {
        center.removePendingNotificationRequests(withIdentifiers: [Identifier.morning])
    }

    func scheduleInactivityReminders() async {
        guard isInactivityReminderEnabled, isAuthorized else {
            return
        }

        let now = Date()
        guard isAllowedReminderTime(now) else {
            return
        }

        let deliveredCount = await deliveredInactivityReminderCount(for: now)
        saveInactivityReminderCount(deliveredCount, for: now)
        guard deliveredCount < 3 else {
            return
        }

        cancelInactivityReminders()

        for offset in 1...(3 - deliveredCount) {
            let deliveryDate = now.addingTimeInterval(TimeInterval(offset * 60 * 60))
            guard isAllowedReminderTime(deliveryDate) else {
                break
            }

            let content = UNMutableNotificationContent()
            content.title = "水分、ちゃんと取ってる？"
            content.body = "飲み切ったら開いてね。"
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: inactivityIdentifier(for: now, sequence: deliveredCount + offset),
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(
                    timeInterval: TimeInterval(offset * 60 * 60),
                    repeats: false
                )
            )
            try? await center.add(request)
        }
    }

    func cancelInactivityReminders() {
        center.removePendingNotificationRequests(
            withIdentifiers: inactivityIdentifiers(for: .now)
        )
    }

    private var isAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional
    }

    private func isAllowedReminderTime(_ date: Date) -> Bool {
        let hour = calendar.component(.hour, from: date)
        return (7..<22).contains(hour)
    }

    private func deliveredInactivityReminderCount(for date: Date) async -> Int {
        let deliveredNotifications = await center.deliveredNotifications()
        return deliveredNotifications.filter {
            $0.request.identifier.hasPrefix(inactivityIdentifierPrefix(for: date))
        }.count
    }

    private func inactivityIdentifiers(for date: Date) -> [String] {
        (1...3).map { inactivityIdentifier(for: date, sequence: $0) }
    }

    private func inactivityIdentifier(for date: Date, sequence: Int) -> String {
        "\(inactivityIdentifierPrefix(for: date)).\(sequence)"
    }

    private func inactivityIdentifierPrefix(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%@.%04d%02d%02d",
            Identifier.inactivityPrefix,
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    private func saveInactivityReminderCount(_ count: Int, for date: Date) {
        let day = calendar.startOfDay(for: date).timeIntervalSinceReferenceDate
        UserDefaults.standard.set(day, forKey: Keys.inactivityReminderDate)
        UserDefaults.standard.set(count, forKey: Keys.inactivityReminderCount)
    }
}
