//
//  VisitedRestaurantView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 31.08.26.
//
// Display a place card for the selected Restaurant

import MapKit
import SwiftUI

struct VisitedRestaurantView: View {
    var visitedRestaurants: [MKMapItem]
    @State private var selection: MapSelection<MKMapItem>?
    
    var body: some View {
        Map(selection: $selection){
            ForEach(visitedRestaurants, id: \.self) { restaurant in
                    Marker(item: restaurant)
                    .tag(MapSelection(restaurant))
            }
            .mapItemDetailSelectionAccessory(.callout)
        }
        .mapFeatureSelectionAccessory(.callout)
    }
}

#Preview {
    // Sample MKMapItems for preview
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

    return VisitedRestaurantView(visitedRestaurants: [item1, item2, item3])
}
