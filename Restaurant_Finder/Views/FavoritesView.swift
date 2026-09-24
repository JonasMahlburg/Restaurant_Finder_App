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
    @State private var selectedFavoriteID: FavoriteRestaurant.ID?
    @State private var detailItem: MKMapItem?

    var body: some View {
        Group {
            if favoritesManager.favorites.isEmpty {
                ContentUnavailableView {
                    Label("Keine Favoriten", systemImage: "star.slash")
                } description: {
                    Text("Markiere Restaurants als Favoriten, indem du auf den Stern tippst.")
                }
            } else {
                let sortedFavorites = favoritesManager.favorites.sorted(by: { $0.dateAdded > $1.dateAdded })

                List(sortedFavorites, id: \.id, selection: $selectedFavoriteID) { favorite in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(favorite.name)
                            .font(.headline)

                        if let categoryRaw = favorite.category {
                            let category = MKPointOfInterestCategory(rawValue: categoryRaw)
                            Text(categoryName(for: category))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Text(favorite.place ?? "Unbekannter Ort")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            favoritesManager.removeFavorite(id: favorite.id)
                        } label: {
                            Label("Entfernen", systemImage: "trash")
                        }
                    }
                }
                .onChange(of: selectedFavoriteID) { _, newID in
                    guard let newID, let favorite = sortedFavorites.first(where: { $0.id == newID }) else { return }
                    selectedFavoriteID = nil
                    presentDetail(for: favorite)
                }
            }
        }
        .navigationTitle("Favoriten")
        .navigationBarTitleDisplayMode(.large)
        .mapItemDetailSheet(item: $detailItem)
    }

    // Löst zunächst das vollständige MKMapItem auf und präsentiert die Sheet erst danach -
    // die Sheet übernimmt später gesetzte Werte nicht, wenn item bei der Präsentation
    // bereits belegt (oder nil) war
    private func presentDetail(for favorite: FavoriteRestaurant) {
        Task {
            detailItem = await favorite.resolvedMapItem()
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
