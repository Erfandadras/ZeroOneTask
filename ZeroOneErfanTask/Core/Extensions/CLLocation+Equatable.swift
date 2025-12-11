//
//  CLLocation+Equatable.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/12/25.
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    
}
