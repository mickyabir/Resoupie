//
//  Data.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
