//
//  Ingredient.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct Ingredient: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var quantity: String
    var unit: String
}
