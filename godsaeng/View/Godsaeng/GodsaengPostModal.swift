//
//  GodsaengPostModal.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/16.
//

import SwiftUI

struct GodsaengPostModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var godsaengVM: GodSaengViewModel = GodSaengViewModel()
    @State var newGodsaeng: Godsaeng = Godsaeng()
    @State var title: String = ""
    @State var weeks: [String] = []
    @State var description: String = ""
    
    @State var textInputAccepted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                //제목 입력창
                VStack(alignment: .leading) {
                    VStack(spacing: 6) {
                        TextField("같생 제목 (4-15자)", text: $title)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.leading, 2)
                            .onAppear {
                                UIApplication.shared.hideKeyboard()
                            }
                            .onChange(of: title) { val in
                                //닉네임 개수 검사
                                if val.count >= 4 && val.count <= 15 {
                                    textInputAccepted = true
                                } else {
                                    textInputAccepted = false
                                }
                            }
                        Rectangle()
                            .frame(width: screenWidth * 0.9, height: 3)
                            .foregroundColor(.lightGray)
                            .padding(.top, -5)
                    }
                }
                .padding(.leading)
                .padding()
                //요일 선택창
                WeekDaysButton()
                //설명 입력창
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                    .frame(width: screenWidth * 0.9, height: 200)
                    .overlay (
                        TextEditor(text: $description)
                            .onChange(of: description) { val in
                                //닉네임 개수 검사
                                if val.count <= 25 {
                                    textInputAccepted = true
                                } else {
                                    textInputAccepted = false
                                }
                            }
                            .overlay(
                                Text(description == "" ? "어떤 같생인가요?" : "")
                                    .foregroundColor(.accent5)
                                    .offset(x: 50, y: -50)
                            )
                    )
                    .padding()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        postGodsaeng()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces) == "" || weeks == [] || description.trimmingCharacters(in: .whitespaces) == "")
                }
            }
        }
    }
    
    @ViewBuilder
    func WeekDaysButton() -> some View {
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        HStack(spacing: 10) {
            ForEach(weekdays, id: \.self) { day in
                Button(action: {
                    if let index = weeks.firstIndex(of: day) {
                        weeks.remove(at: index)
                    } else {
                        weeks.append(day)
                    }
                }, label: {
                    Circle()
                        .frame(width: 41, height: 41)
                        .foregroundColor(weeks.contains(day) ? .mainOrange : .darkGray.opacity(0.2))
                        .overlay(
                            Text(day)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(weeks.contains(day) ? .white : .black)
                        )
                })
            }
        }
    }
    
    func postGodsaeng() {
        newGodsaeng.title = title
        var englishWeekdays = KoreandayToEnglishDay(days: weeks)
        newGodsaeng.weeks = englishWeekdays
        newGodsaeng.description = description
        print(newGodsaeng)
        if let token = try? TokenManager.shared.getToken() {
            godsaengVM.creatGodsaeng(accessToken: token, godsaengToCreate: newGodsaeng)
        }
    }
    
}

struct GodsaengPostModal_Previews: PreviewProvider {
    static var previews: some View {
        GodsaengPostModal()
    }
}
