//
//  TutorialView.swift
//  DrinkUp-NextWAY
//
//  Created by よっちゃん on 2026/04/15.
//

import SwiftUI

struct TutorialView: View {
    
    var onFinish: () -> Void
    
    @State private var step = 0
    
    var body: some View {
        ZStack {
            Color(red: 186/255, green: 217/255, blue: 255/255)
                .ignoresSafeArea()
            
            
            VStack(spacing: 24) {
                
                Spacer()
                
                if step == 0 {
                    VStack(spacing: 16) {
                        // App Icon Display
                        Image("AppIconLight")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 140)
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("水分をシンプルに記録")
                            .font(.title)
                            .foregroundColor(Color.black)
                            .bold()
                        
                        Text("水筒を使うことで、簡単に正確な記録ができます。")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .bold()
                    }
                }
                
                else if step == 1 {
                    VStack(spacing: 16) {
                        Text("飲んだら青いボタンを押す")
                            .font(.title)
                            .foregroundColor(Color.black)
                            .bold()
                        Image("+300")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .cornerRadius(40)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("水筒の中身を飲み切ったらタップ、\n長押しで一時的に自由入力できます。")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .bold()
                    }//+300
                }
                
                else if step == 2 {
                    VStack(spacing: 16) {
                        Text("間違えたらiPhoneを振る")
                            .font(.title)
                            .foregroundColor(Color.black)
                            .bold()
                        Image("Undo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .cornerRadius(40)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("最後にした記録が取り消されます。\niPhoneを投げないように気をつけてください★")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .bold()
                    }
                }
                
                else {
                    VStack(spacing: 16) {
                        Text("ヘルスケア連携")
                            .font(.title)
                            .foregroundColor(Color.black)
                            .bold()
                        HStack{
                            Image("Icon - Apple Health")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100)
                                .cornerRadius(20)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Image("AppIconLight")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100)
                                .cornerRadius(20)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        Text("記録をヘルスケアに保存できます。\n選択は任意です。")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .bold()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if step < 3 {
                        step += 1
                    } else {
                        onFinish()
                    }
                }) {
                    Text(step < 2 ? "次へ" : "はじめる")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
    
    #Preview {
        TutorialView {
            // プレビュー用なので何もしない
        }
    }

