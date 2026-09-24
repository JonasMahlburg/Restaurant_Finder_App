//
//  SearchCityView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 15.09.26.
//

import MapKit
import SwiftUI

struct SearchCityView: View {
    @StateObject private var viewModel = CitySearchViewModel()
    @ObservedObject var favoritesManager: FavoritesManager
    @State private var selectedRestaurant: MKMapItem?
    @State private var citySearchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Städtesuche oben
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Stadt suchen", text: $citySearchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .onSubmit {
                        viewModel.searchCity(citySearchText)
                    }
                
                if !citySearchText.isEmpty {
                    Button {
                        citySearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button("Suchen") {
                    viewModel.searchCity(citySearchText)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            
            // Restaurant-Liste
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
                            
                            // Entfernung vom Stadtzentrum
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
            .overlay {
                if viewModel.isSearching {
                    ProgressView("Suche Restaurants...")
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                } else if viewModel.restaurants.isEmpty && viewModel.cityName == nil {
                    ContentUnavailableView(
                        "Keine Stadt ausgewählt",
                        systemImage: "building.2",
                        description: Text("Gib eine Stadt ein, um Restaurants zu finden")
                    )
                } else if viewModel.restaurants.isEmpty && viewModel.cityName != nil {
                    ContentUnavailableView(
                        "Keine Restaurants gefunden",
                        systemImage: "fork.knife.circle",
                        description: Text("In \(viewModel.cityName ?? "dieser Stadt") wurden keine Restaurants gefunden")
                    )
                }
            }
        }
        .navigationTitle(viewModel.cityName ?? "Stadt suchen")
        .navigationBarTitleDisplayMode(.inline)
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
    @Previewable @State var favoritesManager = FavoritesManager()
    NavigationStack {
        SearchCityView(favoritesManager: favoritesManager)
    }
}
