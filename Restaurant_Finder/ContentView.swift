//
//  ContentView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
//

import MapKit
import SwiftUI
import WishKit

struct ContentView: View {
    @ObservedObject var viewModel: RestaurantSearchViewModel
    @State private var selectedRestaurant: MKMapItem?
    
    
    var body: some View {
        NavigationStack{
            List(
                viewModel.restaurants,
                id: \.self,
                selection: $selectedRestaurant
            ) { restaurant in
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
            }
            .mapItemDetailSheet(item: $selectedRestaurant)
            .searchable(text: $viewModel.searchText, prompt: "Restaurant suchen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        WishKit.show()
                    } label: {
                        Image(systemName: "lightbulb")
                    }
                }
            }
        }
        .navigationTitle("In deiner Nähe")
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
    // Sample MKMapItems for preview
    let viewModel = RestaurantSearchViewModel()
    
    let item1: MKMapItem = {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Restaurant Alpha"
        return mapItem
    }()

    let item2: MKMapItem = {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.5176, longitude: 13.4094), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Bistro Bravo"
        return mapItem
    }()

    let item3: MKMapItem = {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 52.5150, longitude: 13.3777), addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Café Charlie"
        return mapItem
    }()

    viewModel.restaurants = [item1, item2, item3]
    return ContentView(viewModel: viewModel)
}
