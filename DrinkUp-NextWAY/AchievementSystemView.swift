//
//  AchievementSystemView.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/02/18.
//
import Foundation

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
                    
                    Text("毎日の水分摂取量状況を直感的に分かりやすく伝えます。")
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
                            Text("1200 mlからそれ以上\n")
                                .bold()
                        } icon: {
                            Image(systemName: "trophy.fill")
                                .bold()
                                .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        }
                    }
                    
                    Divider()
                    
                    Text("このシステムは、数字を視覚的なフィードバックに変換し成長と達成を通して習慣形成を促します。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    
                    
                    Text("注意！\n厚生労働省によると、成人の1日の最低水分摂取量は1.2Lです。実際の必要量は性別や体格によって異なります。この目安を過度に頼らないでください。\n")
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

