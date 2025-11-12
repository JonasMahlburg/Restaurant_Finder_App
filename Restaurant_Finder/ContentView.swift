//
//  ContentView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 11.11.25.
//

import SwiftUI

struct ContentView: View {
    
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
                
                Form{
                    TextField("Search for a restaurant", text: $searchText)

                }
                Button("Search"){
                    print(searchText)
                }

                }
            }
            .navigationTitle("Restaurant Finder")
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
