//
//  TokenManager.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//


import Foundation
import CryptoKit
import SwiftKeychainWrapper

class TokenManager {
    static let shared = TokenManager()
    private let keychain = KeychainWrapper.standard
    private let key = SymmetricKey(size: .bits256)

    private init() {}

    // 암호화
    func encrypt(_ string: String) throws -> Data {
        let data = string.data(using: .utf8)!
        let sealedBox = try! ChaChaPoly.seal(data, using: key)
        return sealedBox.combined
    }

    // 복호화
    func decrypt(_ data: Data) throws -> String {
        let sealedBox = try! ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try! ChaChaPoly.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8)!
    }

    func saveToken(_ token: String) throws {
        let encryptedToken = try encrypt(token)
        keychain.set(encryptedToken, forKey: "access_token")
    }

    func getToken() throws -> String? {
        if let encryptedToken = keychain.data(forKey: "access_token") {
            let token = try decrypt(encryptedToken)
            return token
        }
        return nil
    }
}
