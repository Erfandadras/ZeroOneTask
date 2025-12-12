//
//  MapDirectionsHelper.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/12/25.
//

import Foundation
import MapKit
import CoreLocation
import UIKit

struct MapDirectionsHelper {
    
    /// Opens directions in Apple Maps
    /// - Parameters:
    ///   - destination: Destination coordinate
    ///   - transportType: Type of transport (car or public transportation)
    ///   - destinationName: Optional name for the destination
    static func openInAppleMaps(
        destination: CLLocationCoordinate2D,
        transportType: TransportType,
        destinationName: String? = nil
    ) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        mapItem.name = destinationName ?? "Hospital"
        
        let launchOptions: [String: Any] = [
            MKLaunchOptionsDirectionsModeKey: transportType == .car ? MKLaunchOptionsDirectionsModeDriving : MKLaunchOptionsDirectionsModeTransit
        ]
        
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    /// Opens directions in Google Maps
    /// - Parameters:
    ///   - destination: Destination coordinate
    ///   - transportType: Type of transport (car or public transportation)
    static func openInGoogleMaps(
        destination: CLLocationCoordinate2D,
        transportType: TransportType
    ) -> Bool {
        let travelMode = transportType == .car ? "driving" : "transit"
        let urlString = "comgooglemaps://?daddr=\(destination.latitude),\(destination.longitude)&directionsmode=\(travelMode)"
        
        guard let url = URL(string: urlString) else { return false }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        } else {
            // Fallback to web version
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(destination.latitude),\(destination.longitude)&travelmode=\(travelMode)"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
                return true
            }
            return false
        }
    }
    
    /// Opens directions in Waze
    /// - Parameters:
    ///   - destination: Destination coordinate
    static func openInWaze(destination: CLLocationCoordinate2D) -> Bool {
        let urlString = "waze://?ll=\(destination.latitude),\(destination.longitude)&navigate=yes"
        
        guard let url = URL(string: urlString) else { return false }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return true
        } else {
            // Fallback to web version
            let webUrlString = "https://www.waze.com/ul?ll=\(destination.latitude),\(destination.longitude)&navigate=yes"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
                return true
            }
            return false
        }
    }
}

