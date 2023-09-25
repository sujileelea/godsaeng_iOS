//
//  godsaengApp.swift
//  godsaeng
//
//  Created by Suji Lee on 2023/08/07.
//

import SwiftUI

@main
struct godsaengApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(AccessManager.shared)        }
    }
}
