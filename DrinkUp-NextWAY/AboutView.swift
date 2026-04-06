//
//  About.swift
//  DrinkUp
//　I named it "DrinkUp!" with the hope that you'll open it right as you finish the last drop.
//  Created by よっちゃん on 2026/02/18.
//

import Foundation
import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("About DrinkUp!")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    // App Icon Display
                    Image(colorScheme == .dark ? "AppIconDark" : "AppIconLight")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 180)
                        .cornerRadius(40)
                        .shadow(radius: 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                    
                    Group {
                        Text("Why I made this app")
                            .font(.headline)
                        
                        Text("I named it \"DrinkUp!\" with the hope that you'll open it right as you finish the last drop.\nDrinkUp! is designed to help you track the water you drink from your water bottle with just a few taps, helping you develop healthy hydration habits. \nIt's a simple and effective way to stay hydrated and make small, positive changes in your daily routine.")
                    }
                    
                    Group {
                        Text("About the Developer")
                            .font(.headline)
                        
                        Text("Created by Yoshihisa Kashima\n")
                    }
                    Group {
                        Text("ATTENTION!")
                            .font(.headline)
                        Text("Actual water requirements vary by gender and body type, so please do not rely excessively on this app's achievement system.\n\n\n")
                    }
                }
                .padding()
            }
            .navigationTitle("About DrinkUp!")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottomLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName:"chevron.down")
                        .bold()
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding([.leading, .bottom], 16)
            }
        }
    }
}
