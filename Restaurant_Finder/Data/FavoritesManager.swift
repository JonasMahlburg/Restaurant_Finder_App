//
//  FavoritesManager.swift
//  Restaurant_Finder
//
//  Verwaltet die Favoriten-Restaurants
//

import Foundation
import MapKit
import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    @Published private(set) var favorites: [FavoriteRestaurant] = []
    
    private let savePath = URL.documentsDirectory.appending(path: "favorites.json")
    
    init() {
        loadFavorites()
    }
    
    // Überprüfe ob ein Restaurant ein Favorit ist
    func isFavorite(_ mapItem: MKMapItem) -> Bool {
        guard let name = mapItem.name else { return false }
        let coordinate = mapItem.location.coordinate
        
        return favorites.contains { favorite in
            favorite.name == name &&
            abs(favorite.latitude - coordinate.latitude) < 0.0001 &&
            abs(favorite.longitude - coordinate.longitude) < 0.0001
        }
    }
    
    // Favorit hinzufügen oder entfernen (Toggle)
    func toggleFavorite(_ mapItem: MKMapItem) {
        if isFavorite(mapItem) {
            removeFavorite(mapItem)
        } else {
            addFavorite(mapItem)
        }
    }
    
    // Favorit hinzufügen
    private func addFavorite(_ mapItem: MKMapItem) {
        guard let name = mapItem.name else { return }
        let coordinate = mapItem.location.coordinate
        
        let favorite = FavoriteRestaurant(
            id: UUID(),
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            category: mapItem.pointOfInterestCategory?.rawValue,
            dateAdded: Date()
        )
        
        favorites.append(favorite)
        saveFavorites()
    }
    
    // Favorit entfernen
    private func removeFavorite(_ mapItem: MKMapItem) {
        guard let name = mapItem.name else { return }
        let coordinate = mapItem.location.coordinate
        
        favorites.removeAll { favorite in
            favorite.name == name &&
            abs(favorite.latitude - coordinate.latitude) < 0.0001 &&
            abs(favorite.longitude - coordinate.longitude) < 0.0001
        }
        
        saveFavorites()
    }
    
    // Favorit entfernen per ID (für SwiftUI List)
    func removeFavorite(id: UUID) {
        favorites.removeAll { $0.id == id }
        saveFavorites()
    }
    
    // Speichere Favoriten persistent
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Fehler beim Speichern der Favoriten: \(error.localizedDescription)")
        }
    }
    
    // Lade Favoriten beim Start
    private func loadFavorites() {
        do {
            let data = try Data(contentsOf: savePath)
            favorites = try JSONDecoder().decode([FavoriteRestaurant].self, from: data)
        } catch {
            // Noch keine Favoriten gespeichert oder Fehler beim Laden
            favorites = []
        }
    }
}

// Modell für gespeicherte Favoriten
struct FavoriteRestaurant: Codable, Identifiable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let category: String?
    let dateAdded: Date
}
