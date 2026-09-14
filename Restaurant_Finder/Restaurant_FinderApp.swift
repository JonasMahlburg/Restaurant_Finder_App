//
//  Restaurant_FinderApp.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
//

import SwiftData
import SwiftUI
import MapKit
import WishKit

@main
struct Restaurant_FinderApp: App {
    @StateObject private var viewModel = RestaurantSearchViewModel()
    
    init() {
        // Konfiguriere WishKit nur wenn API-Key verfügbar ist
        configureWishKit()
    }
    
    private func configureWishKit() {
        // Versuche API-Key aus verschiedenen Quellen zu laden
        let apiKey: String?
        
        #if DEBUG
        // Lokale Entwicklung
        apiKey = "E6FA8A14-E48F-4DE0-A325-797FDA500D01"
        #else
        // Production/Xcode Cloud: Umgebungsvariable
        apiKey = ProcessInfo.processInfo.environment["WISHKIT_API_KEY"]
        #endif
        
        if let key = apiKey {
            WishKit.configure(with: key)
            WishKit.theme.primaryColor = .blue
        } else {
            print("⚠️ WishKit API-Key nicht gefunden. Feedback-Feature deaktiviert.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if viewModel.isSearching {
                    ProgressView("Suche Restaurants in deiner Nähe…")
                        .padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }
                ContentView(viewModel: viewModel)
                    .onAppear {
                        viewModel.startSearchNearbyRestaurants()
                    }
            }
        }
//        .modelContainer(for: Restaurant.self)
    }
}
