//
//  Double.swift
//  Resoupie
//
//  Created by Michael Abir on 3/1/22.
//

import Foundation

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
