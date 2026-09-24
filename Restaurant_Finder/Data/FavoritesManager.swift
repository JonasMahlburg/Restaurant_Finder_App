//
//  FavoritesManager.swift
//  Restaurant_Finder
//
//  Verwaltet die Favoriten-Restaurants
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

@MainActor
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
        let id = UUID()

        let favorite = FavoriteRestaurant(
            id: id,
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            category: mapItem.pointOfInterestCategory?.rawValue,
            dateAdded: Date(),
            place: place(for: mapItem),
            identifierRawValue: mapItem.identifier?.rawValue
        )

        favorites.append(favorite)
        saveFavorites()

        // Viele POI-Suchergebnisse liefern keine addressRepresentations mit,
        // daher zusätzlich per Reverse-Geocoding auflösen, falls nötig
        if favorite.place == nil {
            resolvePlace(for: id, coordinate: coordinate)
        }
    }

    // Ermittelt den Ort (Stadt) eines Restaurants aus den Adressdaten
    private func place(for mapItem: MKMapItem) -> String? {
        let address = mapItem.addressRepresentations
        return address?.cityName ?? address?.regionName
    }

    // Löst den Ort nachträglich per Reverse-Geocoding auf und aktualisiert den Favoriten
    private func resolvePlace(for id: UUID, coordinate: CLLocationCoordinate2D) {
        Task {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let request = MKReverseGeocodingRequest(location: location) else { return }

            guard let resolvedItem = try? await request.mapItems.first,
                  let place = self.place(for: resolvedItem),
                  let index = favorites.firstIndex(where: { $0.id == id }) else { return }

            favorites[index].place = place
            saveFavorites()
        }
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

        // Ort für bereits gespeicherte Favoriten ohne addressRepresentations nachträglich auflösen
        for favorite in favorites where favorite.place == nil {
            resolvePlace(for: favorite.id, coordinate: CLLocationCoordinate2D(latitude: favorite.latitude, longitude: favorite.longitude))
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
    var place: String?
    let identifierRawValue: String?

    // Baut ein einfaches MKMapItem aus den gespeicherten Daten (für die Listenanzeige)
    var mapItem: MKMapItem {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let item = MKMapItem(location: location, address: nil)
        item.name = name
        if let category {
            item.pointOfInterestCategory = MKPointOfInterestCategory(rawValue: category)
        }
        return item
    }

    // Lädt das vollständige MKMapItem nach (mit Öffnungszeiten, Telefon, Adresse etc.),
    // damit die DetailView identisch zur Suche ist
    func resolvedMapItem() async -> MKMapItem {
        guard let identifierRawValue,
              let identifier = MKMapItem.Identifier(rawValue: identifierRawValue) else {
            return mapItem
        }

        let request = MKMapItemRequest(mapItemIdentifier: identifier)
        return (try? await request.mapItem) ?? mapItem
    }
}
