//
//  AchievementSystemView.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/02/18.
//

import Foundation

//
//  AchievementSystemView.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/02/18.
//

import SwiftUI

struct AchievementSystemView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Achievement System")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                    
                    Text("DrinkUp! uses a simple visual growth system to represent your daily hydration progress.")
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Label {
                            Text("0–499 ml\n")
                                .bold()
                        } icon: {
                            Image(systemName: "leaf")
                                .bold()
                                .foregroundStyle(.red)
                        }
                        
                        Label {
                            Text("500–799 ml\n")
                                .bold()
                        } icon: {
                            Image(systemName: "leaf.fill")
                                .bold()
                                .foregroundStyle(.yellow)
                        }
                        
                        Label {
                            Text("800–1199 ml\n")
                                .bold()
                        } icon: {
                            Image(systemName: "tree.fill")
                                .bold()
                                .foregroundStyle(.green)
                        }
                        
                        Label {
                            Text("1200 ml or more\n")
                                .bold()
                        } icon: {
                            Image(systemName: "trophy.fill")
                                .bold()
                                .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        }
                    }
                    
                    Divider()
                    
                    Text("This system transforms numbers into visual feedback, encouraging habit formation through growth and achievement.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    
                    
                    Text("ATTENTION!\nAccording to Japan's Ministry of Health, Labour and Welfare, the minimum daily water intake for adults is 1.2 liters. Actual requirements vary depending on gender and body size. Therefore, do not rely too heavily on this guideline.\n")
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Achievement System")
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

