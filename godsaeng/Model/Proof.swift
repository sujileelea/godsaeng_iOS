//
//  Proof.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//

import Foundation

struct Proof: Codable, Identifiable, Hashable {
    var id: Int?
    var proofId: Int?
    var nickname: String?
    var profileImg: String?
    var date: String?
    var proofImg: String?
    var content: String?
}
