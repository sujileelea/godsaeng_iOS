//
//  CollectionPage.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/15.
//

import SwiftUI

struct CollectionPage: View {
    
    @StateObject var godsaengVM: GodSaengViewModel = GodSaengViewModel()
    @State var showGSPostModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("# 모집중")
                        .font(.system(size: 26, weight: .bold))
                        .padding(.leading)
                        .padding()
                        .padding(.top)
                    //같생 전체 목록
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 5) {
                            ForEach(godsaengVM.godsaengList, id: \.self) { godsaeng in
                                NavigationLink(destination: {
                                    GodsaengDetailPage(godsaengVM: godsaengVM, godsaeng: godsaeng)
                                }, label: {
                                    CollectionGSCell(godsaeng: godsaeng, mode: .extended)
                                })
                                
                            }
                        }
                    }
                }
                Button(action: {
                    showGSPostModal = true
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.mainGreen)
                        .frame(width: screenWidth * 0.89, height: 50)
                        .overlay (
                            Text("새로운 같생 만들기")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        )
                })
                .padding()
            }
            .padding(.leading, 6)
        }
        .sheet(isPresented: $showGSPostModal) {
            GodsaengPostModal()
                .presentationDetents([.large, .fraction(0.6)])
        }
        .onAppear {
            if let token = try? TokenManager.shared.getToken() {
                godsaengVM.fetchGodsaengList(accessToken: token)
            }
        }
    }
}

struct CollectionPage_Previews: PreviewProvider {
    static var previews: some View {
        CollectionPage()
    }
}
