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
                            .font(.title3)
                        
                        Text("「誰もが簡単に確実に水分摂取量を把握できるように、もっと水を飲もうとする気持ちを育む。」という想いから、DrinkUp!は生まれました。\nこのアプリは、ボトルの水分摂取量を数タップで簡単に記録できます。\n日々の中で無理なく水分補給の習慣を身につけるためのシンプルなツールです。")
                    }
                    
                    Group {
                        Text("About the Developer")
                            .font(.title3)
                        Text("製作者")
                            .font(.headline)
                        Text("Yoshihisa Kashima")
                        Text("英語翻訳")
                            .font(.headline)
                        Text("Gerard P Grillo")
                        Text("韓国語翻訳")
                            .font(.headline)
                        Text("韓国のお友達🫰🏻")
                        Text("リンク集")
                            .font(.title3)
                        Link("プライバシーポリシー", destination: URL(string: "https://cubic-bird-aa4.notion.site/DrinkUp-3527ee35cf148064968bc5e367f3eaf7")!)
                        Link("マシュマロ(サポート)", destination: URL(string: "https://marshmallow-qa.com/1mtb1vn4livqyh7")!)
                        Link("Threads", destination: URL(string: "https://www.threads.com/@drinkup_niigata?igshid=NTc4MTIwNjQ2YQ==")!)
                        Link("note", destination: URL(string: "https://note.com/k_yochiyan")!)
                        Link("X", destination: URL(string: "https://x.com/drinkup_niigata?s=21")!)
                    }
                    Group {
                        Text("注意！")
                            .font(.headline)
                        Text("必要な水分量は性別や体型によって異なります。\nAchievement Systemを過度に依存しないでください。\n\n\n")
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
#Preview {
    AboutView()
}
