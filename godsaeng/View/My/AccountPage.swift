//
//  Account.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/15.
//

import SwiftUI

struct AcountPage: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @State private var showAlert = false
    
    var body: some View {
            VStack {
                HStack {
                    Text("계정 정보")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top, 70)
                .padding(.bottom, 30)
                HStack {
                    Text("이메일")
                    Spacer()
                    Text(memberVM.member.email ?? "")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                HStack {
                    Text("로그인 플랫폼")
                    Spacer()
                    Text(memberVM.member.platform ?? "")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                Divider()
                    .padding(.vertical)
                HStack(spacing: 60) {
                    Button(action: {
                        AccessManager.shared.isLoggedIn = false
                        AccessManager.shared.userLoggedOutOrDeleted = true
                    }, label: {
                        Text("로그아웃")
                            .font(.callout)
                            .padding(.top, 30)
                            .foregroundColor(.blue)
                    })
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Text("회원탈퇴")
                            .font(.callout)
                            .padding(.top, 30)
                            .foregroundColor(.red)
                    })
                }
                Spacer()
            }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("회원 탈퇴"),
                message: Text("프로필, 내가 참여한 같생 기록이 사라집니다"),
                primaryButton: .destructive(Text("취소")),
                secondaryButton: .cancel(Text("탈퇴"),action: {
                    AccessManager.shared.isAgreed = false
                    AccessManager.shared.isLoggedIn = false
                    AccessManager.shared.userLoggedOutOrDeleted = true
                    if let token = memberVM.member.token {
                        memberVM.deleteMember(accessToken: token)
                    }
                }))
        }
    }
}
