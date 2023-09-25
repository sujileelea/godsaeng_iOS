//
//  ProofCreateModal.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/16.
//

import SwiftUI
import PhotosUI

struct ProofPostModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var proofVM: ProofViewModel = ProofViewModel()
    @Binding var godsaeng: Godsaeng
    @State var proofToPost: Proof = Proof()
    @State var proofImgData: Data?
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State var content: String = ""
    @State var textInputAccepted: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("같생 인증")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.mainGreen)
                //이미지
                VStack {
                    if let imageData = proofImgData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.88)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                                    self.proofImgData = data
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
                        Image("ProofImgTemplate")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.88)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                                    self.proofImgData = data
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
                //내용
                VStack {
                    TextField("인증을 설명해주세요 (25자 제한)", text: $content)
                        .font(.system(size: 18, weight: .semibold))
                        .onAppear {
                            UIApplication.shared.hideKeyboard()
                        }
                        .onChange(of: content) { val in
                            if val.count <= 25 {
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
                .padding(.leading, 30)
            }
            .padding(.top, -39)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button("취소") {
                        dismiss()
                    }
                })
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        postProof()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespaces) == "" || textInputAccepted == false || proofImgData == nil)
                }
            }
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
    
    func postProof() {
        proofToPost.content = content
        if let imageDataToResize = proofImgData, let imageToResize = UIImage(data: imageDataToResize) {
            let resizedImage = resizeImageMaintainingAspectRatio(image: imageToResize, newWidth: 200)
            let compressedImageData = resizedImage.jpegData(compressionQuality: 1.0)
            if let token = try? TokenManager.shared.getToken() {
                proofVM.createProof(accessToken: token, godsaeng: godsaeng, proofToPost: proofToPost, proofImgData: compressedImageData)
            }
            dismiss()
        }
    }
}

