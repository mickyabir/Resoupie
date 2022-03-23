//
//  Ingredient.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct Ingredient: Hashable, Codable {
//    var id: String
    var name: String
    var quantity: String
    var unit: String
    
    init(name: String, quantity: String, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
