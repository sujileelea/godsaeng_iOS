//
//  SettingPage.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/15.
//

import SwiftUI

struct SettingPage: View {
    
    @ObservedObject var memberVM: MemberViewModel
    var version: String = "1.0.0"
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                NavigationLink(destination: {
                    AcountPage(memberVM: memberVM)
                }, label: {
                    BlockCell(icon: "person", label: "계정 정보")
                })
                Button(action: {
                    if let url = URL(string: "https://www.notion.so/officialgodsaeng/Q-A-78a570b79615460eb9690bd3e2fd60f6") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    BlockCell(icon: "questionmark.circle", label: "Q & A")
                    
                })
                Button(action: {
                    if let url = URL(string: "https://www.notion.so/officialgodsaeng/3b9dec26a9b542fea5ab03fd2185028d") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    BlockCell(icon: "doc.text.magnifyingglass", label: "이용약관")
                })
                Button(action: {
                    if let url = URL(string: "https://www.notion.so/officialgodsaeng/18d3a35bc6d94dd085e50633d01522cc") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    BlockCell(icon: "lock", label: "개인정보 처리 방침")
                })
                Button(action: {
                    if let url = URL(string: "https://www.notion.so/officialgodsaeng/920cca7ca8ef4aab89af2eb6bd2703e6") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    BlockCell(icon: "lock", label: "개인정보 수집 및 이용 동의서")
                })
                Button(action: {
                    if let url = URL(string: "https://www.notion.so/officialgodsaeng/67024362edca49c5a446edf89567e6a4") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    BlockCell(icon: "megaphone", label: "공지사항")
                })
                BlockCell(icon: "info.circle", label: "문의처")
                    .padding(.bottom)
                Text("버전 정보 : \(version)")
                    .foregroundColor(.gray.opacity(0.9))
                    .font(.system(size: 13.5))
            }
            .padding(.top, 40)
        }
    }
    
    @ViewBuilder
    func BlockCell(icon: String, label: String) -> some View {
        VStack {
            Rectangle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.2)
                .foregroundColor(.clear)
                .frame(width: screenWidth, height: 55)
                .overlay(
                    HStack(spacing: 15) {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .padding(.leading)
                        Text(label)
                            .font(.system(size: 17))
                        Spacer()
                        if label == "계정 정보" {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17))
                                .padding(.trailing)
                        }
                        if label == "문의처" {
                            Text("official.godsaeng@gmail.com")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.system(size: 14))
                                .padding(.trailing)
                        }
                    }
                )
        }
    }
}
