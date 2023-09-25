//
//  ProofViewModel.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/11.
//

import Foundation
import Combine

class ProofViewModel: ObservableObject {
    
    @Published var proof: Proof = Proof()

    @Published private var cancellabels = Set<AnyCancellable>()
    
    //인증 생성
    func createProof(accessToken: String, godsaeng: Godsaeng, proofToPost: Proof, proofImgData: Data?) {
        requestProofCreation(accessToken: accessToken, godsaeng: godsaeng, proofToPost: proofToPost, proofImgData: proofImgData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("인증 생성 비동기 종료")
                case .failure(let error):
                    print("인증 생성 비동기 Error: \(error)")
                }
            }, receiveValue: { proofData in
                self.proof.id = proofData.id
            })
            .store(in: &self.cancellabels)
    }
    func requestProofCreation(accessToken: String, godsaeng: Godsaeng, proofToPost: Proof, proofImgData: Data?) -> Future<Proof, Error> {
        var godsaengId: Int = godsaeng.id ?? 0
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs/proof/\(godsaengId)") else {
                fatalError("유효하지 않은 url")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let boundary = UUID().uuidString
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let data = self.createBody(with: ["proofImg": proofImgData, "proof": proofToPost], boundary: boundary)
            request.httpBody = data
            
            URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("인증 생성 상태코드 200")
                    case 401:
                        print("인증 생성 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500:
                        print("인증 생성 상태코드 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("인증 생성 상태 코드 : \(httpResponse.statusCode)")
                    }
                    return  data
                }
                .decode(type: Proof.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("같생 생성 요청 종료")
                    case .failure(let error):
                    print("같생 생성 요청 Error : \(error)")
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.cancellabels)
        }
    }
    
    private func createBody(with parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        for (key, value) in parameters {
            if key == "proof" {
                if let proof = value as? Proof {
                    do {
                        let jsonEncoder = JSONEncoder()
                        let jsonData = try jsonEncoder.encode(proof)
                        body.append(Data("--\(boundary)\r\n".utf8))
                        body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n".utf8))
                        body.append(Data("Content-Type: application/json\r\n\r\n".utf8))
                        body.append(jsonData)
                        body.append(Data("\r\n".utf8))
                        
                    } catch {
                        print("Error encoding Proof: \(error)")
                    }
                }
            } else if let image = value as? Data {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image.jpg\"\r\n".utf8))
                body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
                body.append(image)
                body.append(Data("\r\n".utf8))
            }
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }

}
