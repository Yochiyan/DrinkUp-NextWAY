//
//  ContentView.swift
//  How many drink water?
//
//  Created by よっちゃん on 2025/09/18.
//

import SwiftUI
import UIKit
import Combine
import Foundation
import HealthKit
struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var settings = AppSettings()
    @State private var bottles: [Bottle] = []
    @State private var records: [DrinkRecord] = []
    @State private var inputSize = ""
    @State private var today = Date()
    @State private var now: Date = Date()
    @State private var showSettings: Bool = false
    @State private var showSavingInfo: Bool = false
    @State private var showHistory: Bool = false
    @State private var showAchievementSystemView: Bool = false
    @State private var showCustomAddSheet: Bool = false
    @State private var customAddInput: String = ""
    @State private var showTutorial = false // チュートリアル表示フラグ
    @State private var lastDeletedRecord: DrinkRecord? = nil//振って取り消し
    @State private var showUndoToast: Bool = false
    @State private var isAdding: Bool = false
    let healthStore = HKHealthStore()
    
    func requestHealthKitPermission(){
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }

        healthStore.requestAuthorization(toShare: [waterType], read: []) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error)")
            }
        }
    }
    
    func saveWaterToHealthKit(amount: Int) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let quantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: Double(amount))

        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: Date(),
            end: Date()
        )

        healthStore.save(sample) { success, error in
            if let error = error {
                print("HealthKit save error: \(error)")
            }
        }
    }
    // MARK: - Subviews to reduce type-checking complexity
    
    private func HeaderView(bottle: Bottle) -> some View {
        let value = todayTotal()

        if settings.unitSystem == .ml {
            return (
                Text("今日:")
                + Text(" \(value)ml")
            )
            .font(.largeTitle)
            .fontWeight(.bold)

        } else {
            let oz = settings.mlToOz(value)

            return (
                Text("今日oz:")
                + Text(" \(String(format: "%.1f", oz))oz")
            )
            .font(.largeTitle)
            .fontWeight(.bold)
        }
    }
    
    @ViewBuilder
    private func ActionButtons() -> some View {
        HStack(spacing: 20) {
            Button {
                showSettings = true
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("設定")
                        .font(.system(size: 20))
                }
                .environment(\.locale, .current)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.clear)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(colorScheme == .dark ? .white.opacity(0.35) : Color.gray, lineWidth: 1)
            )
            //.shadow(color: .black.opacity(0.2), radius: 10, y: 6)
            
            Button {
                showHistory = true
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text("履歴")
                        .font(.system(size: 20))
                }
                //.foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.clear)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(colorScheme == .dark ? .white.opacity(0.35) : Color.gray, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    //StreakDays
    private func SavingsView(total: Int) -> some View {
        HStack(spacing: 8) {
            Text("連続日数: \(streakDays())日")
                .bold()
                .environment(\.locale, .current)
        }
    }
    
    @ViewBuilder
    //Achivement System
    private func IndicatorView(totalToday: Int) -> some View {
        HStack(spacing: 40) {
            Image(systemName: "leaf")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor((0...499).contains(totalToday) ? .red : .gray)
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor((500...799).contains(totalToday) ? .yellow : .gray)
            
            Image(systemName: "tree.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor((800...1199).contains(totalToday) ? .green : .gray)
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(totalToday >= 1200 ? Color(red: 1.0, green: 0.84, blue: 0.0) : .gray)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .environment(\.locale, .current)
    }
    
    @ViewBuilder
    //+ml Button
    private func AddButton(bottle: Bottle) -> some View {
        Button(action: {
            if isAdding { return }
            isAdding = true

            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            let newRecord = DrinkRecord(date: Date(), amount: bottle.size)
            records.append(newRecord)
            lastDeletedRecord = nil
            saveWaterToHealthKit(amount: bottle.size)//ヘルスケアへの書き込み

            // 短いクールダウンで連打を防止
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isAdding = false
            }
        }) {
            let addLabel: String = {
                if settings.unitSystem == .ml {
                    return "+\(bottle.size)ml"
                } else {
                    let oz = settings.mlToOz(bottle.size)
                    return String(format: "+%.1foz", oz)
                }
            }()
            Text(addLabel)
                .font(.system(size: 30, weight: .bold))
                .environment(\.locale, .current)
                .fontWeight(.bold)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
        .disabled(isAdding)
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    customAddInput = ""
                    showCustomAddSheet = true
                }
        )
        .alert("マイボトル以外の水分補給", isPresented: $showCustomAddSheet) {
            let placeholder: String = {
                if settings.unitSystem == .ml {
                    return "\(bottle.size)ml"
                } else {
                    return String(format: "%.1foz", settings.mlToOz(bottle.size))
                }
            }()
            TextField(placeholder, text: $customAddInput)
                .keyboardType(settings.unitSystem == .ml ? .numberPad : .decimalPad)
            Button("キャンセル", role: .cancel) {
                customAddInput = ""
            }
            Button("追加") {
                if isAdding { return }
                switch settings.unitSystem {
                case .ml:
                    if let value = Int(customAddInput), value > 0 {
                        isAdding = true
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        let record = DrinkRecord(date: Date(), amount: value)
                        records.append(record)
                        saveWaterToHealthKit(amount: value)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { isAdding = false }
                    }
                case .oz:
                    if let oz = Double(customAddInput), oz > 0 {
                        isAdding = true
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        let ml = settings.ozToMl(oz)
                        let record = DrinkRecord(date: Date(), amount: ml)
                        records.append(record)
                        saveWaterToHealthKit(amount: ml)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { isAdding = false }
                    }
                }
                customAddInput = ""
            }
        } message: {
            Text("もしかして：超能力者ですか？")
        }
    }
    
    @ViewBuilder
    private func RecordsList() -> some View {
        List(records.indices.reversed(), id: \.self) { index in
            let record = records[index]
            VStack(alignment: .leading) {
                let amountText: String = {
                    if settings.unitSystem == .ml {
                        return "\(record.amount) ml"
                    } else {
                        let oz = settings.mlToOz(record.amount)
                        return String(format: "%.1f oz", oz)
                    }
                }()
                Text(amountText).fontWeight(.bold)
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    /*-----------------------------------------------------------------------------*/
    @ViewBuilder
    //WelcomeView
    private func WelcomeView() -> some View {
        VStack(spacing: 30) {
            Text(colorScheme == .dark ? "こんばんは！" : "こんにちは！")
                .font(.title)
                .font(.largeTitle)
                .environment(\.locale, .current)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("簡単に水分補給の記録ができます。")
                .font(.title2)
                .environment(\.locale, .current)
                .padding(16)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.gray)
        }
        .padding(80)
        .background(
            LinearGradient(
                gradient: Gradient(colors:
                                    colorScheme == .dark
                                   ? [Color(red: 0.6, green: 0.3, blue: 0.3),
                                      Color(red: 0.1, green: 0.0, blue: 0.2)]
                                   : [Color.blue, Color.white]
                                  ),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(40)
            .padding(16)
            .shadow(radius: 10)
        )
        
        
        let unitLabel = settings.unitSystem == .ml ? "ml" : "oz"

        Picker("単位", selection: $settings.unitSystem) {
            Text("ml").tag(AppSettings.UnitSystem.ml)
            Text("oz").tag(AppSettings.UnitSystem.oz)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)

        Text("マイボトルの容量を入力してください(\(unitLabel))")
            .environment(\.locale, .current)
            .bold()
        
        let welcomePlaceholder = settings.unitSystem == .ml ? "300" : "10.1"
        TextField(welcomePlaceholder, text: $inputSize)
            .keyboardType(settings.unitSystem == .ml ? .numberPad : .decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 200)
            .toolbar {
                
                ToolbarItemGroup(placement: .keyboard) {
                    
                    Spacer()
                    
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                }
            }
        
        
        Button("Start!") {
            switch settings.unitSystem {
            case .ml:
                if let size = Int(inputSize), size > 0 {
                    let newBottle = Bottle(size: size)
                    bottles = [newBottle]
                }
            case .oz:
                if let oz = Double(inputSize), oz > 0 {
                    let ml = settings.ozToMl(oz)
                    let newBottle = Bottle(size: ml)
                    bottles = [newBottle]
                }
            }
        }
        .padding()
        .environment(\.locale, .current)
        .background(Color.blue)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .cornerRadius(10)
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
        
        // プライバシーポリシー同意文＆リンク
        Text("Start!を押すと[プライバシーポリシー](https://cubic-bird-aa4.notion.site/DrinkUp-3527ee35cf148064968bc5e367f3eaf7)に同意したものとします。")
            .font(.footnote)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
    // チュートリアル初回チェック
    private func checkFirstTutorial() {
        let key = "didShowTutorial"
        if !UserDefaults.standard.bool(forKey: key) && !bottles.isEmpty {
            showTutorial = true
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    

    private func resetAllState() {
        bottles = []
        records = []
        inputSize = ""
        today = Date()
        now = Date()
        showSettings = false
        showSavingInfo = false
        showHistory = false
        showAchievementSystemView = false
        showCustomAddSheet = false
        customAddInput = ""
        showTutorial = false

        settings.waterPrice = 0
        settings.vendingSize = 0
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 40) {
                
                if let bottle = bottles.first {
                    HeaderView(bottle: bottle)

                    ActionButtons()
                        .fullScreenCover(isPresented: $showSettings) {
                            if let index = bottles.indices.first {
                                SettingsView(bottle: $bottles[index])
                                    .environmentObject(settings)
                            }
                        }
                        .sheet(isPresented: $showHistory) {
                            HistoryView(records: records)
                                .environmentObject(settings)
                        }
                    //Information
                    let week = weekTotal()
                    if settings.unitSystem == .ml {
                        Text("今週: \(week)ml").font(.headline)
                    } else {
                        let weekOz = settings.mlToOz(week)
                        Text(String(format: "今週: %.1foz", weekOz)).font(.headline)
                    }

                    let total = records.reduce(0) { $0 + $1.amount }
                    if settings.unitSystem == .ml {
                        Text("今まで: \(total)ml")
                            .font(.headline)
                            .environment(\.locale, .current)
                    } else {
                        let totalOz = settings.mlToOz(total)
                        Text(String(format: "今まで: %.1foz", totalOz))
                            .font(.headline)
                            .environment(\.locale, .current)
                    }

                    SavingsView(total: total)

                    let totalToday = todayTotal()
                    IndicatorView(totalToday: totalToday)
                        .sheet(isPresented: $showAchievementSystemView) {
                            AchievementSystemView()
                        }
                    
                    Button {
                        showAchievementSystemView = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "info.bubble")
                            Text("Achievement System")
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        //Achievement System explain
                    }
                    .buttonStyle(.plain)

                    AddButton(bottle: bottle)

                    RecordsList()
                } else {
                    WelcomeView()
                }
            }
            // Undo Toast UI overlay
            if showUndoToast, let last = lastDeletedRecord {
                HStack {
                    Text("直近の記録が取り消されました！")
                        .bold()
                    Spacer()
                    Button("元に戻す") {
                        records.append(last)
                        lastDeletedRecord = nil
                        showUndoToast = false
                    }
                    .bold()
                    .foregroundColor(.yellow)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
            if let last = records.last {
                lastDeletedRecord = last
                records.removeLast()
                showUndoToast = true

                // 自動で数秒後に消す
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showUndoToast = false
                }
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView {
                requestHealthKitPermission()
                showTutorial = false
            }
        }
        //Update
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            today = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            today = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("startTutorial"))) { _ in
            showTutorial = true
        }
        .onAppear {
            loadData()
        }
        .onChange(of: bottles) { newValue in
            if !newValue.isEmpty {
                checkFirstTutorial()
            }
        }
        .onChange(of: bottles) { _ in
            saveData()
        }
        .onChange(of: records) { _ in
            saveData()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didResetAllData"))) { _ in
            resetAllState()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { value in
            now = value
            today = value
        }
    }
    
    // Today's Total
    private func todayTotal() -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: today)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return records
            .filter { $0.date >= start && $0.date < end }
            .reduce(0) { $0 + $1.amount }
    }
    
    // WeekTotal()
    private func weekTotal() -> Int {
        let cal = Calendar.current
            guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: today) else {
                return 0
            }
            return records
                .filter {
                    $0.date >= weekInterval.start &&
                    $0.date < weekInterval.end
                }
                .reduce(0) { $0 + $1.amount }
        }
    
    //StreakDays()
    private func streakDays() -> Int {
        let cal = Calendar.current
        let uniqueDays = Set(records.map { cal.startOfDay(for: $0.date) })

        let todayStart = cal.startOfDay(for: today)

        let hasTodayRecord = uniqueDays.contains(todayStart)

        let startDay: Date

        // 今日記録している場合
        if hasTodayRecord {
            startDay = todayStart
        } else {

            // 昨日に記録がなければ streak終了
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: todayStart),
                  uniqueDays.contains(yesterday) else {
                return 0
            }

            // 昨日までは継続扱い
            startDay = yesterday
        }

        var streak = 0
        var currentDay = startDay

        while uniqueDays.contains(currentDay) {
            streak += 1

            guard let previousDay = cal.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }

            currentDay = previousDay
        }

        return streak
    }
    
    private func hasRecordedToday() -> Bool {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: today)

        return records.contains {
            cal.isDate($0.date, inSameDayAs: todayStart)
        }
    }
    
    // MARK: - UserDefaults Persistence
    private func saveData() {
        if let bottleData = try? JSONEncoder().encode(bottles) {
            UserDefaults.standard.set(bottleData, forKey: "bottles")
        }
        if let recordData = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(recordData, forKey: "records")
        }
    }

    private func loadData() {
        if let bottleData = UserDefaults.standard.data(forKey: "bottles"),
           let decodedBottles = try? JSONDecoder().decode([Bottle].self, from: bottleData) {
            bottles = decodedBottles
        }

        if let recordData = UserDefaults.standard.data(forKey: "records"),
           let decodedRecords = try? JSONDecoder().decode([DrinkRecord].self, from: recordData) {
            records = decodedRecords
        }
    }
}
#Preview {
    ContentView()
}


extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// MARK: - Keyboard Dismiss Helpers
func dismissKeyboard() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}

extension View {
    /// Dismisses the keyboard by resigning first responder.
    func hideKeyboard() {
        dismissKeyboard()
    }
}

