//
//  DetailView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 13.11.25.
//

import SwiftData
import SwiftUI

struct DetailView: View {
    var restaurant: Restaurant

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(restaurant.image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
           
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(restaurant.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Stil: \(restaurant.style)", systemImage: "paintpalette")
                    Label("Art: \(restaurant.kind)", systemImage: "fork.knife")
                    Label("Preisklasse: \(restaurant.price)", systemImage: "dollarsign.circle")
                    Label("Öffnungszeiten: \(restaurant.hours)", systemImage: "clock")
                    
                    if let childfriendly = restaurant.childfriendly {
                        Label(childfriendly ? "Kinderfreundlich" : "Nicht kinderfreundlich",
                              systemImage: childfriendly ? "figure.and.child.holdinghands" : "nosign")
                    }
                    Label("\(restaurant.review)", systemImage: "note.text")
                        .clipShape(.capsule)
                        .background(.yellow)
                        .foregroundStyle(.primary)
                }
                .font(.body)
            }
            .padding()
        }
        .navigationTitle(restaurant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

func loadRestaurants() -> [Restaurant] {
    guard let url = Bundle.main.url(forResource: "Test_Restaurants", withExtension: "json") else {
        print("FEHLER: Datei-URL nicht gefunden. Prüfen Sie Dateiname und Target Membership.")
        return []
    }

    guard let data = try? Data(contentsOf: url) else {
        print("FEHLER: Daten konnten nicht von der URL geladen werden.")
        return []
    }

    do {
        let restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
        return restaurants
    } catch {
        print("FEHLER: JSON-Dekodierung fehlgeschlagen: \(error)")
        return []
    }
}

#Preview {
    let restaurants = loadRestaurants()
    if let first = restaurants.first {
        DetailView(restaurant: first)
    } else {
        Text("Keine Testdaten gefunden.")
    }
}
