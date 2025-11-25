//
//  ContentView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Restaurant.name) private var recentRestaurants: [Restaurant]
    
    @State private var restaurant: Restaurant? = nil
    @State private var searchText: String = ""
    
    
    var body: some View {
        NavigationStack{
            Section{
                NavigationLink("Create New Restaurant"){
                    NewRestaurantView()
                }
                VStack{
                    Image("restaurant")
                        .resizable()
                        .scaledToFit()
                    
                }
                VStack{
                    Text("Recent Searches:")
                    NavigationLink("Explore"){
                        OverViewView()
                    }
                }
            }
            .navigationTitle("Restaurant Finder")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
