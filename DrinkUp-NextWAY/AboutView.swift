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
                    
                    Text("DrinkUp!")
                        .font(.title)
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
                    
                    // App Version
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

                    Text("Version \(version) (\(build))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Divider()
                    
                    Group {
                        Text("Why I made this app")
                            .font(.headline)
                        
                        Text("「最後の一滴を飲み干した瞬間に開いてほしい」という想いから、DrinkUp!と名付けました。\nこのアプリは、ボトルの水分摂取量を数タップで簡単に記録できます。\n日々の中で無理なく水分補給の習慣を身につけるためのシンプルなツールです。")
                    }
                    
                    Group {
                        Text("About the Developer")
                            .font(.headline)
                        
                        Text("Yoshihisa Kashima")
                        Link("マシュマロ", destination: URL(string: "https://marshmallow-qa.com/1mtb1vn4livqyh7")!)
                    }
                    Group {
                        Text("注意！")
                            .font(.headline)
                        Text("必要量な水分は性別や体型によって異なります。\nAchievement Systemを過度に依存しないでください。\n\n\n")
                    }
                }
                .padding()
            }
            .navigationTitle("DrinkUp!について")
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
