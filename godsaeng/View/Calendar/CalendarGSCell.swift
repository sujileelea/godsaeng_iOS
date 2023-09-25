//
//  GodsaengCellInCalendar.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/16.
//

import SwiftUI

struct CalendarGSCell: View {
    
    @State var godsaeng: Godsaeng
    @State var showProofPostModal: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(godsaeng.isDone ?? true ? Color.mainGreen.opacity(0.2) : Color.darkGray.opacity(0.2), lineWidth: 1.5)
                .frame(width: screenWidth * 0.92, height: 90)
                .foregroundColor(.clear)
            HStack {
                Text(godsaeng.title ?? "")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading)
                Spacer()
                Button(action: {
                    if godsaeng.isDone ?? false == false {
                        showProofPostModal = true
                    }
                }, label: {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 80, height: 30)
                        .foregroundColor(godsaeng.isDone ?? true ? .mainGreen : .mainOrange)
                        .overlay (
                            Text(godsaeng.isDone ?? true ? "인증완료" : "인증하기")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        )
                })
                .disabled(godsaeng.isDone == true)
                .padding(.trailing)
            }
            .frame(width: screenWidth * 0.9, height: 100)
        }
        .sheet(isPresented: $showProofPostModal) {
            ProofPostModal(godsaeng: $godsaeng)
                .presentationDetents([.large, .fraction(0.8)])
        }
    }
}
