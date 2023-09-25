//
//  DateUtils.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/13.
//

import Foundation

//요일 한국어->영어
func KoreandayToEnglishDay(days: [String]) -> [String] {
    let translationDict: [String: String] = [
        "월": "MON",
        "화": "TUE",
        "수": "WED",
        "목": "THU",
        "금": "FRI",
        "토": "SAT",
        "일": "SUN"
    ]
    
    return days.compactMap { translationDict[$0] }
}

//요일 영어->한국어 번역
func translateDays(days: [String]) -> [String] {
    let translationDict: [String: String] = [
        "MON": "월",
        "TUE": "화",
        "WED": "수",
        "THU": "목",
        "FRI": "금",
        "SAT": "토",
        "SUN": "일"
    ]
    return days.compactMap { translationDict[$0] }
}

//같은 날인지 검사
func isSameDay(date1: Date,date2: Date) -> Bool {
    let calendar = Calendar.current
    
    return calendar.isDate(date1, inSameDayAs: date2)
}

//년도와 월 구하기
func getYearAndMonth(currentDate: Date) -> [String] {
    
    let calendar = Calendar.current
    let month = calendar.component(.month, from: currentDate)
    let year = calendar.component(.year, from: currentDate)
    
    return ["\(year)", "\(month)"]
}

//현재 월 구하기
func getCurrentMonth(currentMonth: Int) -> Date {
    
    let calendar = Calendar.current
    guard let currentMonth = calendar.date(byAdding: .month, value: currentMonth, to: Date()) else{
        return Date()
    }
    
    return currentMonth
}

//날짜 추출
func extractDate(currentMonth: Int) -> [DateValue] {
    
    let calendar = Calendar.current
    let currentMonth = getCurrentMonth(currentMonth: currentMonth)
    var days = currentMonth.getAllDates().compactMap { date -> DateValue in
        let day = calendar.component(.day, from: date)
        return DateValue(day: day, date: date)
    }
    let firstWeekday = calendar.component(.weekday, from: days.first!.date)
    
    for _ in 0..<firstWeekday - 1{
        days.insert(DateValue(day: -1, date: Date()), at: 0)
    }
    
    return days
}

func getMonthFromDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M"
    return formatter.string(from: date)
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

func convertDateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func getFirstDayOfMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)
    return calendar.date(from: components) ?? Date()
}
