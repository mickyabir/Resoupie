//
//  Grocerylist.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct GroceryList: Hashable, Codable, Identifiable {
    var id: String
    var name: String
    var items: [GroceryListItem]
}
