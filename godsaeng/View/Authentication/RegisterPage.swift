//
//  RegisterPage.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/07.
//

import SwiftUI
import PhotosUI
import UIKit

struct RegisterPage: View {
    
    @ObservedObject var memberVM: MemberViewModel
        
    @State var nickname: String = ""
    @State var profileImageData: Data?
    @State var selectedPhotos: [PhotosPickerItem] = []
    
    @State var isDuplicated: Bool?
    @State var textInputAccepted: Bool = false
    @State var nicknameHasNumber: Bool = false
    @State var nicknameHasSpecial: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                //헤더 텍스트
                VStack {
                    Text("회원가입")
                        .font(.system(size: 26, weight: .bold))
                        .padding(.bottom, 35)
                    VStack(alignment: .leading) {
                        Text("프로필 설정")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.accent4)
                            .padding(.bottom, 7)
                        Text("나를 잘 나타내는 사진과 닉네임을 정해주세요")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.darkGray)
                        Text("프로필은 같생을 함께할 사람들에게 보여집니다")
                            .font(.system(size: 16))
                            .foregroundColor(.darkGray)
                    }
                    .padding(.leading, -15)
                }
                .padding(.bottom, 45)
                //프로필 이미지
                VStack {
                    if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.48, height: screenWidth * 0.48)
                            .clipShape(Circle())
                            .overlay(
                                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                                    Circle()
                                        .stroke(Color.darkGray.opacity(0.4), lineWidth: 1)
                                        .foregroundColor(.clear)
                                }
                                    .onChange(of: selectedPhotos) { newItem in
                                        guard let item = selectedPhotos.first else {
                                            return
                                        }
                                        item.loadTransferable(type: Data.self) { result in
                                            switch result {
                                            case .success(let data):
                                                if let data = data {
                                                    self.profileImageData = data
                                                } else {
                                                    print("data is nil")
                                                }
                                            case .failure(let failure):
                                                fatalError("\(failure)")
                                            }
                                        }
                                    }
                            )
                    } else {
                        Image("DefaultProfile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.48)
                            .clipShape(Circle())
                            .overlay(
                                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                                    Circle()
                                        .foregroundColor(.clear)
                                }
                                    .onChange(of: selectedPhotos) { newItem in
                                        guard let item = selectedPhotos.first else {
                                            return
                                        }
                                        item.loadTransferable(type: Data.self) { result in
                                            switch result {
                                            case .success(let data):
                                                if let data = data {
                                                    self.profileImageData = data
                                                } else {
                                                    print("data is nil")
                                                }
                                            case .failure(let failure):
                                                fatalError("\(failure)")
                                            }
                                        }
                                    }
                            )
                    }
                }
                .padding(.bottom, 20)
                //닉네임 입력창
                VStack(alignment: .leading) {
                    VStack(spacing: 6) {
                        TextField("닉네임 (변경불가)", text: $nickname)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.leading, 5)
                            .onAppear {
                                UIApplication.shared.hideKeyboard()
                            }
                            .onChange(of: nickname, perform: { newValue in
                                checkNicknameDuplication(nickname: newValue)
                                print(newValue)
                            })
                            .onChange(of: nickname) { val in
                                //닉네임 개수 검사
                                if val.count >= 2 && val.count <= 5 {
                                    textInputAccepted = true
                                } else {
                                    textInputAccepted = false
                                }
                                //닉네임 숫자 검사
                                let numbers = CharacterSet.decimalDigits
                                nicknameHasNumber = val.unicodeScalars.contains(where: numbers.contains)
                                if nicknameHasNumber == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                                //닉네임 특수문자 검사
                                let specialCharacter = CharacterSet(charactersIn: " !\"#$%&'()*+,-./:;<=>?@[]^_`{|}~")
                                nicknameHasSpecial =  val.unicodeScalars.contains(where: specialCharacter.contains)
                                if nicknameHasSpecial == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                            }
                        Rectangle()
                            .frame(width: screenWidth * 0.9, height: 3)
                            .foregroundColor(.lightGray)
                            .padding(.top, -5)
                    }
                    VStack {
                        if nickname.count < 2 || nickname.count > 5 || nicknameHasNumber == true || nicknameHasSpecial == true {
                            Text("닉네임은 한글과 영어 2~5자로 입력해주세요")
                        } else {
                            if isDuplicated != nil {
                                if isDuplicated == true{
                                    Text("중복된 닉네임입니다")
                                } else if isDuplicated == false {
                                    Text("사용할 수 있는 닉네임입니다")
                                        .font(.system(size: 14))
                                        .foregroundColor(.mainGreen)
                                }
                            }
                        }
                    }
                    .padding(.leading, 4)
                    .font(.system(size: 14))
                    .foregroundColor(.alertRed)
                }
                .padding(.leading)
            }
            .padding(.top, -80)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        postNewMember()
                    }, label: {
                        Text("완료")
                    })
                    .disabled(nickname.trimmingCharacters(in: .whitespaces) == "" || isDuplicated == nil || isDuplicated == true || textInputAccepted == false || profileImageData == nil)
                }
            }
        }
    }
    
    func checkNicknameDuplication(nickname: String) {
        memberVM.checkNicknameDuplicationToServer(nicknameToCheck: nickname)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("중복검사 비동기 실패")
                    print("중복검사 Error: \(error.localizedDescription)")
                case .finished:
                    if let isDuplicated = memberVM.isDuplicated {
                        self.isDuplicated = isDuplicated
                    }
                    print("Nickname check completed.")
                }
            }, receiveValue: { isDuplicate in
                
            })
            .store(in: &memberVM.cancellables)
    }
    
    func resizeImageMaintainingAspectRatio(image: UIImage, newWidth: CGFloat) -> UIImage {
        let aspectRatio = image.size.height / image.size.width
        let newHeight = newWidth * aspectRatio
        
        let size = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
    
    func postNewMember() {
        if let imageDataToResize = profileImageData, let imageToResize = UIImage(data: imageDataToResize) {
            let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
            let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0)
            memberVM.member.nickname = self.nickname
            memberVM.member.imgData = compressedImageData
            if let token = try? TokenManager.shared.getToken() {
                memberVM.requestRegisterToServer(accessToken: token)
                    .sink(receiveCompletion: { result in
                        switch result {
                        case .failure(let error):
                            print("회원가입 error: \(error)")
                        case .finished:
                            break
                        }
                    }, receiveValue: { data in
                    })
                    .store(in: &memberVM.cancellables)
            }
        }
    }
}
