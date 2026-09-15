//
//  ContentView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
    

import MapKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: RestaurantSearchViewModel
    @ObservedObject var favoritesManager: FavoritesManager
    @State private var selectedRestaurant: MKMapItem?
    @State private var showingFeedback = false
    @State private var showingFavorites = false
    
    
    var body: some View {
        NavigationStack{
            List(
                viewModel.restaurants,
                id: \.self,
                selection: $selectedRestaurant
            ) { restaurant in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name ?? "Restaurant")
                            .font(.headline)
                        
                        HStack {
                            // Küchen-Art / Kategorie
                            if let category = restaurant.pointOfInterestCategory {
                                Text(categoryName(for: category))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Entfernung
                            if !viewModel.formattedDistance(to: restaurant).isEmpty {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(viewModel.formattedDistance(to: restaurant))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Favoriten-Button
                    Button {
                        favoritesManager.toggleFavorite(restaurant)
                    } label: {
                        Image(systemName: favoritesManager.isFavorite(restaurant) ? "star.fill" : "star")
                            .foregroundStyle(favoritesManager.isFavorite(restaurant) ? .yellow : .gray)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .mapItemDetailSheet(item: $selectedRestaurant)
            .searchable(text: $viewModel.searchText, prompt: "Restaurant suchen")
            .navigationTitle("In deiner Nähe")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingFavorites = true
                    } label: {
                        Label("Favoriten", systemImage: "star.fill")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFeedback = true
                    } label: {
                        Label("Feedback", systemImage: "lightbulb")
                    }
                }
            }
            .sheet(isPresented: $showingFeedback) {
                NavigationStack {
                    FeedbackView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fertig") {
                                    showingFeedback = false
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showingFavorites) {
                NavigationStack {
                    FavoritesView(favoritesManager: favoritesManager)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Fertig") {
                                    showingFavorites = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    // Übersetzt die POI-Kategorie in lesbare Namen
    private func categoryName(for category: MKPointOfInterestCategory) -> String {
        switch category {
        case .restaurant:
            return "Restaurant"
        case .cafe:
            return "Café"
        case .bakery:
            return "Bäckerei"
        case .brewery:
            return "Brauerei"
        case .winery:
            return "Weingut"
        case .nightlife:
            return "Bar/Club"
        case .foodMarket:
            return "Lebensmittelmarkt"
        default:
            return "Gastronomie"
        }
    }

}

#Preview {
    @Previewable @State var viewModel = RestaurantSearchViewModel()
    @Previewable @State var favoritesManager = FavoritesManager()
    ContentView(viewModel: viewModel, favoritesManager: favoritesManager)
}
