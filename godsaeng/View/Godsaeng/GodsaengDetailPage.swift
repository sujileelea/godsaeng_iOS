//
//  GodsaengDetailPage.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/16.
//

import SwiftUI
import SDWebImageSwiftUI

struct GodsaengDetailPage: View {
    
    @ObservedObject var godsaengVM: GodSaengViewModel
    @State var godsaeng: Godsaeng
    @State var localIsJoined: Bool = false
    @State var showAlert: Bool = false

    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 0) {
                    Text(godsaengVM.godsaeng.title ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading)
                        .padding(.top)
                    Text(godsaengVM.godsaeng.description ?? "")
                        .font(.system(size: 16))
                        .foregroundColor(.accent5)
                }
                .padding(.bottom, 5)
                VStack(spacing: 4) {
                    HStack(spacing: 1) {
                        Text(godsaengVM.godsaeng.openDate ?? "")
                        Text("부터")
                            .padding(.trailing, 4)
                        Text(godsaengVM.godsaeng.closeDate ?? "")
                        Text("까지")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.accent5)
                    WeekDayCell()
                }
                .padding(.bottom)
                //같생 전체 목록
                HStack {
                    Text("총")
                        .padding(.leading)
                    if let memberCount = godsaengVM.godsaeng.members?.count {
                        Text(String(describing: memberCount))
                            .bold()
                    }
                    Text("명의 같생이 함께해요")
                    Spacer()
                }
                .foregroundColor(.accent5)
                .font(.system(size: 20))
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(godsaengVM.godsaeng.members ?? [], id: \.self) { member in
                            MemberCell(member: member)
                        }
                    }
                    .padding(.horizontal)
                }
                Divider()
                    .padding()
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(godsaengVM.godsaeng.proofs ?? [], id: \.self) { proof in
                            ProofCell(proof: proof)
                        }
                    }
                    .padding(.vertical)
                }
            }
            if let isJoined = godsaengVM.godsaeng.isJoined {
                if !isJoined && !localIsJoined{
                    Button(action: {
                        joinGodsaeng()
                        localIsJoined = true
                    }, label: {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.mainGreen)
                            .frame(width: screenWidth * 0.89, height: 50)
                            .overlay (
                                Text("함께하기")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    })
                    .padding()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text("이제부터 함께!"), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            if let token = try? TokenManager.shared.getToken() {
                godsaengVM.fetchGodsaengDetail(accessToken: token, godsaengId: godsaeng.id ?? 0)
            }
        }
    }
    
    @ViewBuilder
    func WeekDayCell() -> some View {
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        var koreanWeeks = translateDays(days: godsaengVM.godsaeng.weeks ?? [])
        
        HStack(spacing: 10) {
            ForEach(weekdays, id: \.self) { day in
                Circle()
                    .frame(width: 41, height: 41)
                    .foregroundColor(koreanWeeks.contains(day) ? .mainOrange : .darkGray.opacity(0.2))
                    .overlay(
                        Text(day)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(koreanWeeks.contains(day) ? .white : .black)
                    )
            }
        }
    }
    
    @ViewBuilder
    func MemberCell(member: Member) -> some View {
        VStack(spacing: 0) {
            WebImage(url: URL(string: member.profile ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(member.name ?? "알 수 없음")
                .font(.system(size: 13))
        }
    }
    
    @ViewBuilder
    func ProofCell(proof: Proof) -> some View {
        VStack(spacing: 8) {
            HStack {
                WebImage(url: URL(string: proof.profileImg ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.leading)
                Text(proof.nickname ?? "")
                Spacer()
            }
            WebImage(url: URL(string: proof.proofImg ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth * 0.9, height: screenWidth * 0.77)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accent4.opacity(0.5), lineWidth: 0.5)
                )
            Text(proof.content ?? "")
        }
    }
    
    func joinGodsaeng() {
        if let token = try? TokenManager.shared.getToken() {
            godsaengVM.joinGodsaeng(accessToken: token, godsaengToJoin: godsaeng)
        }
    }
    
    
}
