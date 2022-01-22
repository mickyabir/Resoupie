//
//  GroceryList.swift
//  CookBook
//
//  Created by Michael Abir on 1/20/22.
//

import Foundation

struct GroceryList: Hashable, Codable, Identifiable {
    var id: Int
    var list: [String]
}
