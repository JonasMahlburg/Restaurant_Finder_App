//
//  MapView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 31.08.26.
//
// Finding restaurants in Celle

import MapKit
import SwiftUI



struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var restaurants: [MKMapItem] = []

    var body: some View {
        Map(position: $position) {
            ForEach(restaurants, id: \.self) { restaurant in
            Marker(item: restaurant)
            }
        }
        .task {
            guard let celle = await findCity() else {
                return
            }
            restaurants = await findRestaurant(in: celle)
        }
    }
    
    //MARK: - Finding Methods
    
    func findCity() async -> MKMapItem?  {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "celle"
        
        request.addressFilter = MKAddressFilter(
            including: .locality
        )
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        
        return response?.mapItems.first
    }
    
    private func findRestaurant(
        in city: MKMapItem
    ) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        let downtown = MKCoordinateRegion(
            center: city.location.coordinate,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01
                       )
    )
        request.region = downtown
        request.regionPriority = .required
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        
        return response?.mapItems ?? []
    }
}

#Preview {
    MapView()
}
