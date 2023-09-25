//
//  GodsaengCard.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/13.
//

import SwiftUI

enum GodsaengCardType {
    case compact
    case extended
}

struct CollectionGSCell: View {
    
    @State var godsaeng: Godsaeng
    var mode: GodsaengCardType
    
    var body: some View {
            //전체 카드
        HStack(alignment: .top) {
                //구분선
                Rectangle()
                    .fill(Color.mainOrange)
                    .frame(width: 2.5, height: 65)
                    .padding(.trailing, 10)
                //내용
                VStack(alignment: .leading, spacing: 10) {
                    //윗줄
                    //같생 제목
                    VStack(alignment: .leading) {
                        HStack(spacing: 20) {
                            Text(godsaeng.title ?? "")
                                .foregroundColor(.accent4)
                                .font(.system(size: 17, weight: .bold))
                            //같생 요일
                            HStack {
                                if godsaeng.weeks?.count == 7 {
                                    Text("매일")
                                } else {
                                    var koreanWeekdays = translateDays(days: godsaeng.weeks ?? [])
                                    ForEach(koreanWeekdays, id: \.self) { weekday in
                                        Text(weekday)
                                    }
                                }
                            }
                            .foregroundColor(.mainOrange)
                            .font(.system(size: 15, weight: .medium))
                        }
                    }
                    .padding(.top, 1)
                    //아럇줄
                    //같생 설명
                    Text(godsaeng.description?.prefix(25) ?? "")
                        .font(.system(size: 15))
                        .foregroundColor(.accent4)
                }
            }
            .padding()
    }
}

