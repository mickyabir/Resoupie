//
//  CLGeocoder.swift
//  Resoupie
//
//  Created by Michael Abir on 2/28/22.
//

import Foundation
import Combine
import CoreLocation

extension CLGeocoder {
    func reverseGeocodeLocationCombine(location: CLLocation) -> Future<(String?, String?), Never> {
        return Future() { promise in
            self.reverseGeocodeLocation(location) { placemarks, error in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let placemarks = placemarks {
                    let pm = placemarks as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks[0]
                        promise(Result.success((pm.country, pm.locality)))
                    }
                }
            }
        }
    }
}
