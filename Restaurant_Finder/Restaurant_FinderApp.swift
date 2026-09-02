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
        // WishKit konfigurieren mit API-Key aus sicherer Konfigurationsdatei
        WishKit.configure(with: APIKeys.wishKit)
        
        // Optional: Theme anpassen
        WishKit.theme.primaryColor = .blue
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
