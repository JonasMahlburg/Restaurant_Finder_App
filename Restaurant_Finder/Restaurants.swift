//
//  Restaurants.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 12.11.25.
//

import Foundation
import SwiftData

@Model
class Restaurant {
    

    var name: String
    var location: String
    var image: String
    var childfriendly: Bool?
    var type: String
    var kind: String
    var price: String
    var hours: String
    var phone: String
    var review: String
    

    init(name: String, location: String, image: String, childfriendly: Bool? = nil, type: String, kind: String, price: String, hours: String, phone: String, review: String) {
        self.name = name
        self.location = location
        self.image = image
        self.childfriendly = childfriendly
        self.type = type
        self.kind = kind
        self.price = price
        self.hours = hours
        self.phone = phone
        self.review = review
    }
}
