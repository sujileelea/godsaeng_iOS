//
//  ProfileImageEditModal.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/15.
//

import SwiftUI
import PhotosUI

struct ProfileImageEditModal: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @State var profileImageDataToUpdate: Data?
    @State var selectedPhotos: [PhotosPickerItem] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 6) {
                Text("프로필 변경")
                    .font(.system(size: 22, weight: .semibold))
                Text("나를 나타내보세요!")
                    .foregroundColor(.darkGray)
                    .font(.system(size: 16))
                    .padding(.bottom, 60)
                //이미지
                if let imageData = profileImageDataToUpdate, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.48)
                        .clipShape(Circle())
                        .padding(.top, -50)
                        .overlay(
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 1, matching: .images) {
                                Circle()
                                    .foregroundColor(.clear)
                                    .frame(width: 300)
                                    .offset(y: -30)
                            }
                                .onChange(of: selectedPhotos) { newItem in
                                    guard let item = selectedPhotos.first else {
                                        return
                                    }
                                    item.loadTransferable(type: Data.self) { result in
                                        switch result {
                                        case .success(let data):
                                            if let data = data {
                                                self.profileImageDataToUpdate = data
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("취소") {
                        dismiss()
                    }
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("저장") {
                        updateProfileImage()
                    }
                })
            }
        }
        .onAppear {
            profileImageDataToUpdate = memberVM.member.imgData
        }
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
    
    func updateProfileImage() {
        if let imageDataToResize = profileImageDataToUpdate, let imageToResize = UIImage(data: imageDataToResize) {
            let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
            let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0)
            memberVM.member.imgData = compressedImageData
            if let token = try? TokenManager.shared.getToken() {
                memberVM.updateProfileImage(accessToken: token, imageDataToUpdate: compressedImageData)
            }
        }
    }
}
