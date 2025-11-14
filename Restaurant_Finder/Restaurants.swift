//
//  Restaurants.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 12.11.25.
//

import Foundation

@Observable
class Restaurant: Codable, Identifiable{
    enum CodingKeys: String, CodingKey{
        case _name = "name"
        case _location = "location"
        case _image = "image"
        case _childfriendly = "childfriendly"
        case _style = "style"
        case _art = "art"
        case _price = "price"
    }
    
    var name: String
    var location: String
    var image: String
    var childfriendly: Bool?
    var style: String
    var art: String
    var price: String
}
