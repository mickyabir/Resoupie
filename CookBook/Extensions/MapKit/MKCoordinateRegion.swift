//
//  MKCoordinateRegion.swift
//  CookBook
//
//  Created by Michael Abir on 2/26/22.
//

import MapKit

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.span.latitudeDelta == rhs.span.latitudeDelta && lhs.span.longitudeDelta == rhs.span.longitudeDelta && lhs.center.latitude == rhs.center.latitude && lhs.center.longitude == rhs.center.longitude
    }
}
