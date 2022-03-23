//
//  User.swift
//  Resoupie
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

struct User: Codable {
    var name: String
    var username: String
    var user_id: String
    var followers: Int
    var recipe_count: Int
    var bio: String
    var location: String
}
