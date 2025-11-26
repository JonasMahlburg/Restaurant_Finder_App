//
//  DetailView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 13.11.25.
//

import SwiftData
import SwiftUI

struct DetailView: View {
    @Environment(\.modelContext) var modelContext
    
    let restaurant: Restaurant

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
                    Label("Stil: \(restaurant.type)", systemImage: "paintpalette")
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

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Restaurant.self, configurations: config)
        let example = Restaurant(name: "Habanero Mexicano", location: "Mexico City", image: "mexico", childfriendly: true, type: "Mexican", kind: "Restauramt", price: "$$", hours: "16:00 - 23:00", phone: "555 345927", review: "increíblemente bueno")
        
        return AnyView(
        DetailView(restaurant: example)
            .modelContainer(container)
        )
    } catch {
        return AnyView(
        Text("Failed to create preview: \(error.localizedDescription)")
        )
    }
}
