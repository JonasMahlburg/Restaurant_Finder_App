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
    @Query(sort:
            [SortDescriptor(\Restaurant.name)
            ])
    var restaurant: [Restaurant]
    
    
    var body: some View {
        NavigationStack{
            Section{
                NavigationLink("Create New Restaurant"){
                    NewRestaurantView()
                }
                Image("restaurant")
                        .resizable()
                        .scaledToFit()
                
                    if restaurant.isEmpty{
                        Text("Add your first restaurant!")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Image(systemName:"photo")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.2)
                            .frame(width: 100, height: 100)
                    }else{
                        List{
                            ForEach(restaurant){ restaurant in
                                NavigationLink(value: restaurant){
                                    HStack{
                                        Image(restaurant.image)
                                            .resizable()
                                            .scaledToFit()
                                        Text(restaurant.name)
                                    }
                                }
                            }
                        }

                        }
                    }
            NavigationLink("Explore"){
                OverView()
            }
            .navigationTitle("Restaurant Finder")
        }
        .padding()
    }

}

#Preview {
    ContentView()
}
