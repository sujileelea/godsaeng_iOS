//
//  AccessManager.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/10.
//

import Foundation

class AccessManager: ObservableObject {
    static let shared = AccessManager()

    @Published private var _isLoggedIn: Bool = false
    @Published private var _isAgreed: Bool = false
    @Published private var _isRegistered: Bool = false
    @Published private var _tokenExpired: Bool = false
    @Published private var _userLoggedOutOrDeleted: Bool = false
    @Published private var _serverDown: Bool = false
    var isLoggedIn: Bool {
        get {
            return self._isLoggedIn
        }
        set {
            self._isLoggedIn = newValue
        }
    }
    var isAgreed: Bool {
        get {
            return self._isAgreed
        }
        set {
            self._isAgreed = newValue
        }
    }
    var isRegistered: Bool {
        get {
            return self._isRegistered
        }
        set {
            self._isRegistered = newValue
        }
    }
    var tokenExpired: Bool {
        get {
            return self._tokenExpired
        }
        set {
            self._tokenExpired = newValue
        }
    }
    var userLoggedOutOrDeleted: Bool {
        get {
            return self._userLoggedOutOrDeleted
        }
        set {
            self._userLoggedOutOrDeleted = newValue
        }
    }
    var serverDown: Bool {
        get {
            return self._serverDown
        }
        set {
            self._serverDown = newValue
        }
    }

    init() {}
}

