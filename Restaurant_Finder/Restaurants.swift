//
//  Restaurants.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 12.11.25.
//

import Foundation
import SwiftData

@Model
final class Restaurant: Codable {
    

    var name: String
    var location: String
    var image: String
    var childfriendly: Bool?
    var style: String
    var kind: String
    var price: String
    var hours: String
    var phone: String
    var review: String
    
    enum CodingKeys: String, CodingKey {
        case name, location, image, childfriendly, style, kind, price, hours, phone, review
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.location = try container.decode(String.self, forKey: .location)
        self.image = try container.decode(String.self, forKey: .image)
        self.childfriendly = try container.decodeIfPresent(Bool.self, forKey: .childfriendly)
        self.style = try container.decode(String.self, forKey: .style)
        self.kind = try container.decode(String.self, forKey: .kind)
        self.price = try container.decode(String.self, forKey: .price)
        self.hours = try container.decode(String.self, forKey: .hours)
        self.review = try container.decode(String.self, forKey: .review)
        self.phone = try container.decode(String.self, forKey: .phone)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(childfriendly, forKey: .childfriendly)
        try container.encode(style, forKey: .style)
        try container.encode(kind, forKey: .kind)
        try container.encode(price, forKey: .price)
        try container.encode(hours, forKey: .hours)
        try container.encode(review, forKey: .review)
        try container.encode(phone, forKey: .phone)
    }

    // Standard-Initializer für die Erstellung von Objekten im Code
    init(name: String, location: String, image: String, childfriendly: Bool? = nil, style: String, kind: String, price: String, hours: String, phone: String, review: String) {
        self.name = name
        self.location = location
        self.image = image
        self.childfriendly = childfriendly
        self.style = style
        self.kind = kind
        self.price = price
        self.hours = hours
        self.phone = phone
        self.review = review
    }
}
