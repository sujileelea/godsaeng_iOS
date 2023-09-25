//
//  Member.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//

import Foundation

struct Member: Hashable, Codable, Identifiable {
    var id: Int?
    var email: String?
    var nickname: String?
    var platform: String?
    var platformId: String?
    var token: String?
    var isRegistered: Bool?
    var result: Bool?
    var imgUrl: String?
    var imgData: Data?
    var name: String?
    var profile: String?
}
