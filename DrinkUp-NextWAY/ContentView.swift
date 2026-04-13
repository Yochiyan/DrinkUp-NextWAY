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
    let healthStore = HKHealthStore()

    func requestHealthKitPermission() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!

        healthStore.requestAuthorization(toShare: [waterType], read: []) { success, error in
            if let error = error {
                print("HealthKit auth error: \(error)")
            }
        }
    }

    func saveWaterToHealthKit(amount: Int) {
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
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
    @ViewBuilder
    private func HeaderView(bottle: Bottle) -> some View {
        Text("Bottle Size: \(bottle.size)ml")
            .environment(\.locale, .current)
            .font(.title)
            .fontWeight(.bold)
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
                        .font(.system(size: 20, weight: .bold))
                }
                .environment(\.locale, .current)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
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

            Button {
                showHistory = true
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text("履歴")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
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
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    //Money Saved
    private func SavingsView(total: Int) -> some View {
        let saving = settings.vendingSize > 0 ? total * settings.waterPrice / settings.vendingSize : 0
        HStack(spacing: 8) {
            Text("Saved money: ¥\(saving)")
                .bold()
                .environment(\.locale, .current)
            Button { showSavingInfo = true } label: {
                Image(systemName: "info.bubble").imageScale(.medium)
                    .bold()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
        }
        .alert("Saved moneyについて", isPresented: $showSavingInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("水を買う代わりに水筒を満杯にすることでどれだけ節約できたかが表示されます。\nこの機能を使用するには、設定で価格と容量を登録してください。")
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

            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            let newRecord = DrinkRecord(date: Date(), amount: bottle.size)
            records.append(newRecord)
            saveWaterToHealthKit(amount: bottle.size)//ヘルスケアへの書き込み
        }) {
            Text("+\(bottle.size)ml")
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
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    customAddInput = ""
                    showCustomAddSheet = true
                }
        )
        .alert("今どのくらい飲んだのか分かるんですか！?", isPresented: $showCustomAddSheet) {
            TextField("\(bottle.size)ml", text: $customAddInput)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) {
                customAddInput = ""
            }
            Button("Add") {
                if let value = Int(customAddInput), value > 0 {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    let record = DrinkRecord(date: Date(), amount: value)
                    records.append(record)
                    saveWaterToHealthKit(amount: value)
                }
                customAddInput = ""

            }
        } message: {
            Text("答えられるもんなら答えてみな。")
        }
    }

    @ViewBuilder
    private func RecordsList() -> some View {
        List(records.indices.reversed(), id: \.self) { index in
            let record = records[index]
            VStack(alignment: .leading) {
                Text("\(record.amount) ml").fontWeight(.bold)
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    @ViewBuilder
    //WelcomeView
    private func WelcomeView() -> some View {
        VStack(spacing: 30) {
            Text("こんにちは！")
                .font(.title)
                .font(.largeTitle)
                .environment(\.locale, .current)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("マイボトルを用意しましたか？")
                .font(.title2)
                .environment(\.locale, .current)
                .padding(16)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.gray)
        }
        .padding(80)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.white]),
                startPoint: .top, endPoint: .bottom
            )
            .cornerRadius(40)
            .padding(16)
            .shadow(radius: 10)
        )

        Text("マイボトルの容量を入力してください(ml)")
            .environment(\.locale, .current)
            .bold()

        TextField("Type here!", text: $inputSize)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 200)

        Button("Start!") {
            if let size = Int(inputSize) {
                let newBottle = Bottle(size: size)
                bottles = [newBottle]
                // ここでHealthKit認証を呼び出す
                let manager = HealthKitManager.shared
                if manager.isAvailable() {
                    manager.requestAuthorization { success in
                        if !success {
                            print("HealthKit authorization failed")
                        }
                    }
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
    }

    var body: some View {
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
                    }
                //Information
                Text("Today's Total: \(todayTotal())ml")
                    .font(.headline)

                let total = records.reduce(0) { $0 + $1.amount }
                Text("Lifetime Total: \(total)ml")
                    .font(.headline)
                    .environment(\.locale, .current)

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
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.blue)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    //Achievement System explain
                }
                .buttonStyle(.plain)

                AddButton(bottle: bottle)
                Text("Tap to add • Long press for custom entry")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                RecordsList()
            } else {
                WelcomeView()
            }
        }
        .padding()
        //Update
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            today = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            today = Date()
        }
        .onAppear {
            loadData()
            // Removed requestHealthKitPermission() call here as per instructions
        }
        .onChange(of: bottles) { _ in
            saveData()
        }
        .onChange(of: records) { _ in
            saveData()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didResetAllData"))) { _ in
            records = []
            bottles = []
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
    
    private func todayCount() -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: today)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return 0 }

        return records
            .filter { $0.date >= start && $0.date < end }
            .count
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

