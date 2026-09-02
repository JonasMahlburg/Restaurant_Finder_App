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
    // Preview zeigt leere Karte - in der echten App werden besuchte Restaurants angezeigt
    VisitedRestaurantView(visitedRestaurants: [])
}
