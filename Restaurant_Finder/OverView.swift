//
//  OverView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 25.11.25.
//

import SwiftData
import SwiftUI

struct OverView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort:[
        SortDescriptor(\Restaurant.name)
    ]) var restaurants : [Restaurant]
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(restaurants) { restaurant in
                    NavigationLink {
                        VStack {
                            Image(restaurant.image)
                                .resizable()
                                .scaledToFit()
                            Text(restaurant.name)
                                .font(.title)
                        }
                        .padding()
                    } label: {
                        HStack {
                            Image(restaurant.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            Text(restaurant.name)
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Restaurant.self, configurations: config)
        
        // 1. Beispiel-Objekte erstellen
        let example = Restaurant(name: "Habanero Mexicano", location: "Mexico City", image: "mexico", childfriendly: true, type: "Mexican", kind: "Restauramt", price: "$$", hours: "16:00 - 23:00", phone: "555 345927", review: "increíblemente bueno")
        let secondExample = Restaurant(name: "Pizzeria Fantastico", location: "Rom", image: "ladolcevita", childfriendly: false, type: "Italienisch", kind: "Restaurant", price: "$$$", hours: "18:00 - 22:00", phone: "555 123456", review: "Beste Pizza der Stadt")
        
        // 2. Objekte speichern/einfügen
        container.mainContext.insert(example)
        container.mainContext.insert(secondExample)
        
        // 3. Wichtig: Die OverView (Listenansicht) muss zurückgegeben werden, nicht die DetailView!
        // Wir verwenden 'return' und 'AnyView', da wir Kontrollfluss nutzen.
        return AnyView(
            OverView() // <-- Überprüfe: Hier sollte OverView stehen, nicht DetailView!
                .modelContainer(container)
        )
        
    } catch {
        // Im Fehlerfall muss auch explizit eine View zurückgegeben werden.
        return AnyView(
            Text("Failed to create preview: \(error.localizedDescription)")
        )
    }
}
