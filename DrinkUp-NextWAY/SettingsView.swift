//
//  BottleEditView.swift
//  DrinkUp!
//
//  Created by よっちゃん on 2025/09/29.
//
import SwiftUI
import Foundation
import HealthKit

extension Notification.Name {
    static let bottleDidUpdate = Notification.Name("bottleDidUpdate")
}

struct SettingsView: View {
    @Binding var bottle: Bottle
    @State private var inputSize: String = ""
    @State private var showInputError: Bool = false
    @State private var showResetAlert: Bool = false
    @State private var showAboutSheet: Bool = false
    
    private enum HealthAuthStatus {
        case unavailable
        case notDetermined
        case denied
        case partial
        case authorized
    }
    @State private var healthAuthStatus: HealthAuthStatus = .notDetermined
    @State private var showHealthHelp: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) private var colorScheme

    private let healthStore = HKHealthStore()
    
    
    var body: some View {
        Form {
            Text("設定")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                .listRowBackground(Color.clear)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(colorForHealthStatus())
                    .frame(width: 10, height: 10)
                Text(healthStatusText())
                    .font(.footnote)
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showHealthHelp = true
            }
            .alert("ヘルスケア権限について", isPresented: $showHealthHelp) {
                Button("閉じる", role: .cancel) {}
                Button("ヘルスケアを開く") {
                    if let url = URL(string: "x-apple-health://"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(healthHelpMessage())
            }
            .listRowBackground(Color.clear)
            
            Section("ボトル内容量(ml)") {
                TextField("(ml)", text: $inputSize)
                    .keyboardType(.numberPad)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                
            }
            .foregroundColor(.secondary)
            .bold()
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)


            Section {
                Button("保存して閉じる") {
                    guard let size = Int(inputSize), size > 0 else {
                        showInputError = true
                        return
                    }

                    bottle.size = size
                    NotificationCenter.default.post(name: .bottleDidUpdate, object: nil)
                    dismiss()
                }
                .listRowBackground(Color(red: 0/255, green: 120/255, blue: 255/255))
                .foregroundColor(Color.white)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Section {
                Button {
                    showAboutSheet = true
                } label: {
                    Text("DrinkUp!について")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.blue, lineWidth: 5)
                        )
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            Section {
                Button("ヘルスケアを開く↗︎") {
                    if let url = URL(string: "x-apple-health://"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                        UIApplication.shared.open(url) { _ in
                              DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                  updateHealthStatus()
                              }
                          }
                    }
                }
                .bold()
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)

            }
            Section {
                Button("チュートリアルを開始") {
                    NotificationCenter.default.post(name: Notification.Name("startTutorial"), object: nil)
                    dismiss()
                }
                .listRowBackground(Color(red: 186/255, green: 217/255, blue: 255/255))
                .foregroundColor(.blue)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Section {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Text("DrinkUp!をリセット")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.red, lineWidth: 5)
                        )
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .alert("本当にリセットしますか？\nこの操作は元に戻せません。", isPresented: $showResetAlert) {
                    Button("キャンセル", role: .cancel) {}
                    Button("続ける", role: .destructive) {
                        resetAllData()
                        UserDefaults.standard.removeObject(forKey: "didShowTutorial")
                    }
                    
                }
            }
            
        }
        //キーボードを閉じるボタン。
        /*.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    hideKeyboard()
                } label: {
                    Image(systemName: "chevron.down")
                }
            }
        }*/
        
        //Bottle capacityで0以下の数字が入っている時
        .alert("扱うことのできない値が含まれています。", isPresented: $showInputError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("0以上の値を入力してください。")
        }
        .onAppear {
            updateHealthStatus()
            inputSize = "\(bottle.size)"
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func healthHelpMessage() -> String {
        switch healthAuthStatus {
        case .authorized:
            return String(localized:"ヘルスケアへの書き込み権限は許可されています。")
            case .partial:
            return String(localized:"一部のみ許可されています。ヘルスケアアプリでDrinkUp!のアクセス権を見直してください。")
        case .denied:
            return String(localized:"ヘルスケアへの書き込み権限が未許可です。ヘルスケアアプリを開いて許可してください。")
        case .notDetermined:
            return String(localized:"ヘルスケアへの書き込み権限が未設定です。初回の権限リクエストや、ヘルスケアアプリから設定できます。")
        case .unavailable:
            return String(localized:"このデバイスではヘルスケアが利用できません。対応デバイスでご利用ください。")
        }
    }
    
    private func updateHealthStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            healthAuthStatus = .unavailable
            return
        }
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            healthAuthStatus = .unavailable
            return
        }
        // HealthKit provides per-type authorizationStatus for read/write. For write, use the same API on the sample type.
        let writeStatus = healthStore.authorizationStatus(for: waterType)
        // Also ask request status to know if authorization is still needed.
        let toShare: Set<HKSampleType> = [waterType]
        healthStore.getRequestStatusForAuthorization(toShare: toShare, read: []) { status, _ in
            DispatchQueue.main.async {
                switch (writeStatus, status) {
                case (.sharingAuthorized, _):
                    self.healthAuthStatus = .authorized
                case (.notDetermined, _):
                    self.healthAuthStatus = .notDetermined
                case (.sharingDenied, _):
                    self.healthAuthStatus = .denied
                default:
                    self.healthAuthStatus = .notDetermined
                }
            }
        }
    }
//ステータスカラー
    private func colorForHealthStatus() -> Color {
        switch healthAuthStatus {
        case .authorized:
            return .green
        case .partial:
            return .yellow
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        case .unavailable:
            return .gray
        }
    }
//ヘルスケア許可状況ステータス。
    private func healthStatusText() -> String {
        switch healthAuthStatus {
        case .authorized:
            return String(localized:"ヘルスケア書き込み: 許可")
        case .partial:
            return String(localized:"ヘルスケア書き込み: 一部のみ")
        case .denied:
            return String(localized: "ヘルスケア書き込み: 未許可")
        case .notDetermined:
            return String(localized:"ヘルスケア書き込み: 未設定")
        case .unavailable:
            return String(localized:"ヘルスケア書き込み: 利用不可")
        }
    }
    
    private func requestHealthAuthorization() {
        // Define the types your app uses. Adjust as needed for DrinkUp!
        guard HKHealthStore.isHealthDataAvailable() else { return }

        // Example: water intake (dietaryWater). Replace or extend types for your app.
        let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)
        let readTypes: Set<HKObjectType> = Set([waterType].compactMap { $0 })
        let shareTypes: Set<HKSampleType> = Set([waterType].compactMap { $0 })

        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            // You could present feedback if needed. For now, do nothing.
        }
    }
    
    private func resetAllData() {
        settings.waterPrice = 0
        settings.vendingSize = 0
        bottle.size = 0
        inputSize = ""

        // Delete saved drink history
        UserDefaults.standard.removeObject(forKey: "records")
        UserDefaults.standard.removeObject(forKey: "bottles")
        NotificationCenter.default.post(name: Notification.Name("didResetAllData"), object: nil)

        dismiss()
    }

}
#Preview {
    BottleEditPreviewWrapper()
}

private struct BottleEditPreviewWrapper: View {
    @State private var sample = Bottle(size: 500)

    var body: some View {
        SettingsView(bottle: $sample)
            .environmentObject(AppSettings())
    }
}
