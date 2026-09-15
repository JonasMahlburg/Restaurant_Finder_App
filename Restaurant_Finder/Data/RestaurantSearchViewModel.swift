import Foundation
import MapKit
import CoreLocation
import SwiftUI
import Combine

@MainActor
final class RestaurantSearchViewModel: NSObject, ObservableObject {
    @Published var restaurants: [MKMapItem] = []
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var userLocation: CLLocation?

    private let locationManager = CLLocationManager()
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
//        .foodMarket //nicht relevant
    ]

    override init() {
        super.init()
        locationManager.delegate = self
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

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startSearchNearbyRestaurants() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        if let location = locationManager.location {
            searchRestaurants(near: location.coordinate)
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    private func searchRestaurants(near coordinate: CLLocationCoordinate2D) {
        isSearching = true
        errorMessage = nil
        
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.userLocation = userLocation
        let maxDistance: CLLocationDistance = 10_000 // 10km in Metern
        
        // Suche nach allen gastronomischen Point of Interest Kategorien
        Task { @MainActor in
            var allResults: [MKMapItem] = []
            
            // Führe Suchen für alle POI-Kategorien parallel aus
            await withTaskGroup(of: [MKMapItem].self) { group in
                for category in foodPOICategories {
                    group.addTask {
                        await self.searchPOICategory(category, near: coordinate, userLocation: userLocation, maxDistance: maxDistance)
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
    }
    
    nonisolated private func searchPOICategory(_ category: MKPointOfInterestCategory, near coordinate: CLLocationCoordinate2D, userLocation: CLLocation, maxDistance: CLLocationDistance) async -> [MKMapItem] {
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
                let distance = userLocation.distance(from: itemLocation)
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
        guard let userLocation = userLocation else {
            return nil
        }
        let itemLocation = mapItem.location
        return userLocation.distance(from: itemLocation)
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

extension RestaurantSearchViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startSearchNearbyRestaurants()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            manager.stopUpdatingLocation()
            Task { @MainActor in
                self.searchRestaurants(near: coordinate)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }
}
