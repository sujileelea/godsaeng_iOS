//
//  GodsaengViewModel.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/11.
//

import Foundation
import Combine

class GodSaengViewModel: ObservableObject {
    
    @Published var godsaengs: Godsaengs = Godsaengs()
    @Published var godsaengList: [Godsaeng] = []
    
    @Published var monthlyGodsaengs: MonthlyGodsaengs = MonthlyGodsaengs()
    @Published var monthlyGodsaengList: [Godsaeng] = []
    
    @Published var dailyGodsaengs: DailyGodsaengs = DailyGodsaengs()
    @Published var dailyGodsaengList: [Godsaeng] = []
    
    @Published var godsaeng: Godsaeng = Godsaeng()
    
    @Published var isFetching: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    func joinGodsaeng(accessToken: String, godsaengToJoin: Godsaeng) {

            guard let godsaengId = godsaengToJoin.id, let url = URL(string: "\(requestURL)/godsaengs/attend/\(godsaengId)") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("같생 참여 error : \(error)")
                    } else if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            print("같생 참여 응답 상태코드 : ", httpResponse.statusCode)
                        } else if httpResponse.statusCode == 401 {
                            AccessManager.shared.tokenExpired = true
                            AccessManager.shared.isLoggedIn = false
                        } else if httpResponse.statusCode == 500 {
                            AccessManager.shared.serverDown = true
                            AccessManager.shared.isLoggedIn = false
                    } else {
                            print("같생 참여 응답 상태코드 : ", httpResponse.statusCode)
                        }
                    }
                }
            }.resume()
    }

    
    //같생 작성
    func creatGodsaeng(accessToken: String, godsaengToCreate: Godsaeng) {
                
        requestgodsaengCreation(accessToken: accessToken, godsaengToCreate: godsaengToCreate)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("같생 생성 비동기 종료")
                case .failure(let error):
                    print("같생 생성 비동기 에러 : \(error)")
                }
            }, receiveValue: { godsaengData in
                self.godsaeng.id = godsaengData.id
            })
            .store(in: &self.cancellables)
    }
    func requestgodsaengCreation(accessToken: String, godsaengToCreate: Godsaeng) -> Future<Godsaeng, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs") else {
                fatalError("Invalid URL")
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            do {
                let jsonData = try JSONEncoder().encode(godsaengToCreate)
                request.httpBody = jsonData
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
            }
            
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("같생 생성 상태코드 200")
                    case 401:
                        print("같생 생성 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500 :
                        print("서버 에러 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("같생 생성 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Godsaeng.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("같생 생성 요청 error : \(error)")
                    }
                } receiveValue: { data in
                    promise(.success(data))
                    self.fetchGodsaengList(accessToken: accessToken)
                }
                .store(in: &self.cancellables)
        }
    }
    
    //같생 전체 조회
    func fetchGodsaengList(accessToken: String) {
        requestGodsaengListFetch(accessToken: accessToken)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("같생 전체 조회 비동기 성공")
                case .failure(let error):
                    print("같생 전체 조회 비동기 error : \(error)")
                }
            }, receiveValue: { godsaengsData in
                self.godsaengs = godsaengsData
                self.godsaengList = godsaengsData.godsaengs ?? []
                print("조회된 같생 전체 목록 : ", self.godsaengList)
            })
            .store(in: &self.cancellables)
    }
    func requestGodsaengListFetch(accessToken: String) -> Future<Godsaengs, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs") else {
                fatalError("같생 전체 조회 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("같생 전체 조회 상태코드 200")
                    case 401:
                        print("같생 전체 조회 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500 :
                        print("같생 전체 조회 서버 에러 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("같생 전체 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Godsaengs.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure( error))
                    case .finished:
                        print("같생 조회 요청 종료")
                        break
                    }
                }, receiveValue: { data in
                    promise(.success(data))
                })
                .store(in: &self.cancellables)
        }
    }
    
    //같생 월별 조회
    func fetchMonthlyGodsaengList(accessToken: String, currentMonth: String) {
        requestMonthlyGodsaengFetch(accessToken: accessToken, currentMonth: currentMonth)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("같생 월별 조회 비동기 성공")
                case .failure(let error):
                    print("같생 월별 조회 비동기 error : \(error)")
                }
            }, receiveValue: { data in
                self.monthlyGodsaengs = data
                self.monthlyGodsaengList = data.monthlyGodsaengs ?? []
            })
            .store(in: &self.cancellables)
    }
    func requestMonthlyGodsaengFetch(accessToken: String, currentMonth: String) -> Future<MonthlyGodsaengs, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs/monthly?date=\(currentMonth)") else {
                fatalError("같생 월별 조회 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                                    
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("같생 월별 조회 상태코드 200")
                    case 401:
                        print("같생 월별 조회 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500 :
                        print("같생 월별 조회 서버 에러 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("같생 월별 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: MonthlyGodsaengs.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure( error))
                    case .finished:
                        print("같생 조회 요청 종료")
                        break
                    }
                }, receiveValue: { data in
                    promise(.success(data))
                    print("월간조회 데이터 : ", data)
                })
                .store(in: &self.cancellables)
        }
    }
    
    //같생 일별 조회
    func fetchDailyGodsaengList(accessToken: String, currentDate: String) {
        requestDailyGodsaengFetch(accessToken: accessToken, currentDate: currentDate)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("같생 일별 조회 비동기 성공")
                case .failure(let error):
                    print("같생 일별 조회 비동기 error : \(error)")
                }
            }, receiveValue: { data in
                self.dailyGodsaengs = data
                self.dailyGodsaengList = data.dailyGodsaengs ?? []
                print(data)
            })
            .store(in: &self.cancellables)
    }
    func requestDailyGodsaengFetch(accessToken: String, currentDate: String) -> Future<DailyGodsaengs, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs/daily?date=\(currentDate)") else {
                fatalError("같생 일별 조회 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("같생 일별 조회 상태코드 200")
                    case 401:
                        print("같생 일별 조회 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500 :
                        print("같생 일별 조회 서버 에러 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("같생 일별 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: DailyGodsaengs.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure( error))
                    case .finished:
                        print("같생 조회 요청 종료")
                        break
                    }
                }, receiveValue: { data in
                    promise(.success(data))
                })
                .store(in: &self.cancellables)
        }
    }
    
    //같생 상세 조회
    func fetchGodsaengDetail(accessToken: String, godsaengId: Int) {
        requestGodsaengDetailFetch(accessToken: accessToken, godsaengId: godsaengId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("같생 조회 비동기 성공")
                case .failure(let error):
                    print("같생 조회 비동기 error : \(error)")
                }
            }, receiveValue: { godsaengData in
                self.godsaeng = godsaengData
            })
            .store(in: &self.cancellables)
    }
    func requestGodsaengDetailFetch(accessToken: String, godsaengId: Int) -> Future<Godsaeng, Error> {
        return Future { promise in
            guard let url = URL(string: "\(requestURL)/godsaengs/\(godsaengId)") else {
                fatalError("같생 상세 조회 Invalid URL")
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
            URLSession.shared.dataTaskPublisher(for: request)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .receive(on: DispatchQueue.main)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("같생 상세 조회 상태코드 200")
                    case 401:
                        print("같생 상세 조회 상태코드 401")
                        AccessManager.shared.tokenExpired = true
                        AccessManager.shared.isLoggedIn = false
                    case 500 :
                        print("같생 상세 조회 서버 에러 500")
                        AccessManager.shared.serverDown = true
                        AccessManager.shared.isLoggedIn = false
                    default:
                        print("같생 상세 조회 상태코드: \(httpResponse.statusCode)")
                    }
                    return data
                }
                .decode(type: Godsaeng.self, decoder: JSONDecoder())
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure( error))
                    case .finished:
                        print("같생 조회 요청 종료")
                        break
                    }
                }, receiveValue: { data in
                    promise(.success(data))
                    print("같생 상세조회 데이터 : ", data)
                })
                .store(in: &self.cancellables)
        }
    }
}
