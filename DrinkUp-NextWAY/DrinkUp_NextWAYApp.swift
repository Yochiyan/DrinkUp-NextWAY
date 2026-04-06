//
//  How_many_drink_water_App.swift
//  How many drink water?
//
//  Created by よっちゃん on 2025/09/18.
//

import SwiftUI
import CoreData
import UIKit

@main
struct DrinkUpApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
