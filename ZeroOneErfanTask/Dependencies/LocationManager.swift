//
//  LocationManager.swift
//  ServiceModule
//
//  Created by Erfan mac mini on 12/28/24.
//

import CoreLocation
import CoreLocationUI
import BaseModule
import SwiftUI
import Combine

@Observable
public class LocationManager: NSObject {
    // MARK: - properties
    private let manager = CLLocationManager()
    private var started: Bool = false
    public var location: CLLocationCoordinate2D?
    public var authorized: Bool?
    public var error: Error?
        
    // MARK: - init
    public override init() {
        super.init()
        manager.delegate = self
    }
    
    public func start() {
        guard !started else { requestLocation(); return }
        checkAuthorization()
        requestLocation()
        started = true
    }
    
    public func stop() {
        location = nil
        started = false
        manager.stopUpdatingLocation()
    }
}

// MARK: - public logics
extension LocationManager: CLLocationManagerDelegate {
    public func checkAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined: authorized = nil
        case .authorizedWhenInUse: authorized = true
        default: authorized = false
        }
    }
    
    public func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard started else {return}
        checkAuthorization()
        requestLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        self.error = error
        Logger.log(.function, level: .error, error.localizedDescription)
    }
}
