//
//  GroceryListItem.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct GroceryListItem: Hashable, Codable, Identifiable {
    var id: String
    var ingredient: String
    var check: Bool
}
