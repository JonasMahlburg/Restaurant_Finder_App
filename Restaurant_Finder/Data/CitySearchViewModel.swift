//
//  CitySearchViewModel.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 15.09.26.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var restaurants: [MKMapItem] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var cityName: String?
    @Published var cityLocation: CLLocation?

    private var allRestaurants: [MKMapItem] = []
    private var searchCancellable: AnyCancellable?
    
    // Alle gastronomischen Point of Interest Kategorien
    private let foodPOICategories: [MKPointOfInterestCategory] = [
        .restaurant,
        .cafe,
        .bakery,
        .brewery,
        .winery,
        .nightlife,
    ]

    init() {
        setupSearchTextObserver()
    }
    
    private func setupSearchTextObserver() {
        // Reagiere auf Änderungen im Suchtext mit Combine
        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterRestaurants(with: searchText)
            }
    }
    
    private func filterRestaurants(with searchText: String) {
        let filtered: [MKMapItem]
        
        if searchText.isEmpty {
            filtered = allRestaurants
        } else {
            filtered = allRestaurants.filter { mapItem in
                guard let name = mapItem.name else { return false }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sortiere nach Entfernung (nächste zuerst)
        restaurants = filtered.sorted { item1, item2 in
            let distance1 = distance(to: item1) ?? Double.infinity
            let distance2 = distance(to: item2) ?? Double.infinity
            return distance1 < distance2
        }
    }

    func searchCity(_ cityName: String) {
        guard !cityName.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        Task { @MainActor in
            // Suche die Stadt
            let cityRequest = MKLocalSearch.Request()
            cityRequest.naturalLanguageQuery = cityName
            cityRequest.resultTypes = [.address]
            
            let citySearch = MKLocalSearch(request: cityRequest)
            
            do {
                let cityResponse = try await citySearch.start()
                
                guard let cityItem = cityResponse.mapItems.first else {
                    self.errorMessage = "Stadt nicht gefunden"
                    self.isSearching = false
                    return
                }
                
                let coordinate = cityItem.placemark.coordinate
                self.cityName = cityItem.name ?? cityName
                self.cityLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                // Suche Restaurants in der Stadt
                await searchRestaurants(near: coordinate)
                
            } catch {
                self.errorMessage = "Fehler bei der Suche: \(error.localizedDescription)"
                self.isSearching = false
            }
        }
    }
    
    private func searchRestaurants(near coordinate: CLLocationCoordinate2D) async {
        guard let cityLocation = cityLocation else { return }
        
        let maxDistance: CLLocationDistance = 10_000 // 10km in Metern
        
        var allResults: [MKMapItem] = []
        
        // Führe Suchen für alle POI-Kategorien parallel aus
        await withTaskGroup(of: [MKMapItem].self) { group in
            for category in foodPOICategories {
                group.addTask {
                    await self.searchPOICategory(category, near: coordinate, cityLocation: cityLocation, maxDistance: maxDistance)
                }
            }
            
            // Sammle alle Ergebnisse
            for await results in group {
                allResults.append(contentsOf: results)
            }
        }
        
        // Entferne Duplikate basierend auf Name und Koordinaten
        let uniqueResults = removeDuplicates(from: allResults)
        
        self.allRestaurants = uniqueResults
        self.filterRestaurants(with: self.searchText)
        self.isSearching = false
    }
    
    nonisolated private func searchPOICategory(_ category: MKPointOfInterestCategory, near coordinate: CLLocationCoordinate2D, cityLocation: CLLocation, maxDistance: CLLocationDistance) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            // Filtere nach Entfernung
            return response.mapItems.filter { mapItem in
                let itemLocation = mapItem.location
                let distance = cityLocation.distance(from: itemLocation)
                return distance <= maxDistance
            }
        } catch {
            return []
        }
    }
    
    nonisolated private func removeDuplicates(from items: [MKMapItem]) -> [MKMapItem] {
        var seen = Set<String>()
        var uniqueItems: [MKMapItem] = []
        
        for item in items {
            // Erstelle einen eindeutigen Identifier basierend auf Name und Koordinaten
            let location = item.location
            let coordinate = location.coordinate
            let identifier = "\(item.name ?? "unknown")_\(coordinate.latitude)_\(coordinate.longitude)"
            
            if !seen.contains(identifier) {
                seen.insert(identifier)
                uniqueItems.append(item)
            }
        }
        
        return uniqueItems
    }
    
    // Helper-Methode um die Entfernung zu berechnen
    func distance(to mapItem: MKMapItem) -> CLLocationDistance? {
        guard let cityLocation = cityLocation else {
            return nil
        }
        let itemLocation = mapItem.location
        return cityLocation.distance(from: itemLocation)
    }
    
    // Helper-Methode um die Entfernung formatiert anzuzeigen
    func formattedDistance(to mapItem: MKMapItem) -> String {
        guard let distance = distance(to: mapItem) else {
            return ""
        }
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}
