//
//  FavoritesView.swift
//  Restaurant_Finder
//
//  Zeigt alle favorisierten Restaurants an
//

import SwiftUI
import MapKit

struct FavoritesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @State private var selectedFavorite: FavoriteRestaurant?
    
    var body: some View {
        Group {
            if favoritesManager.favorites.isEmpty {
                ContentUnavailableView {
                    Label("Keine Favoriten", systemImage: "star.slash")
                } description: {
                    Text("Markiere Restaurants als Favoriten, indem du auf den Stern tippst.")
                }
            } else {
                List {
                    ForEach(favoritesManager.favorites.sorted(by: { $0.dateAdded > $1.dateAdded })) { favorite in
                        Button {
                            selectedFavorite = favorite
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(favorite.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    if let categoryRaw = favorite.category {
                                        let category = MKPointOfInterestCategory(rawValue: categoryRaw)
                                        Text(categoryName(for: category))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Text("Hinzugefügt: \(favorite.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let sortedFavorites = favoritesManager.favorites.sorted(by: { $0.dateAdded > $1.dateAdded })
                        for index in indexSet {
                            favoritesManager.removeFavorite(id: sortedFavorites[index].id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favoriten")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedFavorite) { favorite in
            NavigationStack {
                FavoriteDetailView(favorite: favorite)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fertig") {
                                selectedFavorite = nil
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

// Detail-Ansicht für ein Favoriten-Restaurant
struct FavoriteDetailView: View {
    let favorite: FavoriteRestaurant
    
    var body: some View {
        Map {
            Marker(favorite.name, coordinate: CLLocationCoordinate2D(
                latitude: favorite.latitude,
                longitude: favorite.longitude
            ))
        }
        .navigationTitle(favorite.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if let categoryRaw = favorite.category {
                    let category = MKPointOfInterestCategory(rawValue: categoryRaw)
                    HStack {
                        Image(systemName: "fork.knife")
                        Text(categoryName(for: category))
                        Spacer()
                    }
                    .font(.subheadline)
                }
                
                Button {
                    openInMaps()
                } label: {
                    Label("In Karten öffnen", systemImage: "map")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
        }
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(
            latitude: favorite.latitude,
            longitude: favorite.longitude
        )
        
        // Erstelle MKMapItem für iOS 26
        let mapItem = MKMapItem()
        mapItem.name = favorite.name
        
        // Öffne in Maps
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ])
    }
    
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
    NavigationStack {
        FavoritesView(favoritesManager: FavoritesManager())
    }
}
