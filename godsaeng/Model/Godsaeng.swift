//
//  Godsaeng.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//

import Foundation

struct Godsaeng: Identifiable, Codable, Hashable {
    var id: Int?
    var title: String?
    var description: String?
    var openDate: String?
    var closeDate: String?
    var weeks: [String]?
    var members: [Member]?
    var progress: Int?
    var status: String?     //WAITING, PROGRESSING, CLOSED
    var proofs: [Proof]?
    var isDone: Bool?
    var day: String?        //월별 같생 조회 시 해당 날짜 yyyy-mm-dd
    var isJoined: Bool?
}
