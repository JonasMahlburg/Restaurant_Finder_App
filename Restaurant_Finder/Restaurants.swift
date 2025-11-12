//
//  Restaurants.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 12.11.25.
//

import Foundation

@Observable
class Restaurant: Codable{
    var name: String
    var location: String
    var image: String
    var childfriendly: Bool?
    var style: String
}
