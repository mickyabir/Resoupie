//
//  Place.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import Foundation
import MapKit

struct Place: Identifiable {
    var id: String
    var emoji: String
    var coordinate: CLLocationCoordinate2D
}
