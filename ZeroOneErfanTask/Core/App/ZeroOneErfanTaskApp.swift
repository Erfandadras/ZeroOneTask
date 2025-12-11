//
//  ZeroOneErfanTestApp.swift
//  ZeroOneErfanTest
//
//  Created by Erfan mac mini on 12/11/25.
//

import SwiftUI

@main
struct ZeroOneErfanTaskApp: App {
    
    init() {
        UIFont.loadAll()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MapScreenView()
            }
            .environment(\.colorScheme, .light)
        }
    }
}
