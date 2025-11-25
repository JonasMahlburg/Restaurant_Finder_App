//
//  Restaurant_FinderApp.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
//

import SwiftData
import SwiftUI

@main
struct Restaurant_FinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Restaurant.self)
    }
}
