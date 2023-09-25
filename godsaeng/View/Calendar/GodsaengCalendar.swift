//
//  DatePicker.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//

import SwiftUI

struct GodsaengCalendar: View {
    
    @StateObject var godsaengVM: GodSaengViewModel = GodSaengViewModel()
    
    @State var currentDate: Date = Date()
    @State var currentMonth: Int = 0
    @State var targetMonth: Date = Date()
    @State var targetDate: Date = Date()

    let days: [String] = ["SUN", "Mon","Tue","Wed","Thu","Fri", "Sat"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                HStack {
                    //달력 헤더
                    Button {
                        currentMonth -= 1
                    } label: {
                        Image("ArrowLeft")
                    }
                    Spacer()
                    VStack(spacing: 0) {
                        //년도
                        Text(getYearAndMonth(currentDate: currentDate)[0])
                            .font(.system(size: 16, weight: .medium))
                        //월
                        Text(getMonthFromDate(date: getCurrentMonth(currentMonth: currentMonth)))
                            .font(.system(size: 45, weight: .bold))
                            .foregroundColor(.mainOrange)
                    }
                    .offset(y: -12)
                    Spacer()
                    Button {
                        currentMonth += 1
                    } label: {
                        Image("ArrowRigth")
                    }
                }
                .padding(.horizontal)
                //요일
                HStack(spacing: 0) {
                    ForEach(days, id: \.self){ day in
                        Text(day)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                //날짜들
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(extractDate(currentMonth: currentMonth)) { value in
                        VStack(spacing: 3) {
                            DayCell(value: value)
                                .background(
                                    Circle()
                                        .fill(.black)
                                        .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                                        .offset(y: -5)
                                )
                                .onTapGesture {
                                    currentDate = value.date
                                    targetDate = value.date
                                }

                            if let lineColor = checkIsDone(value: value), value.day != -1 {
                                Rectangle()
                                    .frame(width: 36, height: 2.3)
                                    .foregroundColor(lineColor)
                                    .offset(y: -9)
                            } else {
                                Rectangle()
                                    .frame(width: 36, height: 2.3)
                                    .foregroundColor(.clear)
                                    .offset(y: -19)
                            }
                        }
                    }
                }
                .padding(.bottom, -10)
                //일별 같생 리스트
                VStack(spacing: 10) {
                    ForEach(godsaengVM.dailyGodsaengList, id: \.self) { godsaeng in
                        CalendarGSCell(godsaeng: godsaeng)
                    }
                }
            }
            .padding(.top)
            .padding()
        }
        .padding(.top)
        .onAppear {
            if let token = try? TokenManager.shared.getToken() {
                godsaengVM.fetchMonthlyGodsaengList(accessToken: token, currentMonth: convertDateToString(date: currentDate))
                godsaengVM.fetchDailyGodsaengList(accessToken: token, currentDate: convertDateToString(date: currentDate))
            }
        }
        .onChange(of: currentMonth) { _ in
            let firstDayOfMonth = getFirstDayOfMonth(date: getCurrentMonth(currentMonth: currentMonth))
            targetMonth = firstDayOfMonth
        }
        .onChange(of: targetMonth) { newValue in
            if let token = try? TokenManager.shared.getToken() {
                godsaengVM.fetchMonthlyGodsaengList(accessToken: token, currentMonth: convertDateToString(date: newValue))
            }
        }
        .onChange(of: targetDate) { newValue in
            if let token = try? TokenManager.shared.getToken() {
                godsaengVM.fetchDailyGodsaengList(accessToken: token, currentDate: convertDateToString(date: newValue))
            }
        }
    }
    
    @ViewBuilder
    func DayCell(value: DateValue) -> some View {
        VStack {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(.title3.bold())
                    .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .padding(.vertical, 9)
        .frame(height: 50, alignment: .top)
    }


    func checkIsDone(value: DateValue) -> Color? {
        let matchingGodsaeng = godsaengVM.monthlyGodsaengList.first {
            $0.day == convertDateToString(date: value.date)
        }
        if let godsaeng = matchingGodsaeng {
            if godsaeng.isDone == true {
                return .mainGreen
            } else if godsaeng.isDone == false {
                return .mainOrange
            }
        }
        return nil
    }
}

