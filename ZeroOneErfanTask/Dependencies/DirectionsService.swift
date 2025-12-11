//
//  DirectionsService.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import Foundation
import MapKit
import BaseModule

// MARK: - Protocol
protocol DirectionsServiceProtocol {
    func calculateTravelTime(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType
    ) async throws -> TimeInterval
    
    func calculateAllTravelTimes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async -> (car: TimeInterval?, transit: TimeInterval?, walk: TimeInterval?)
}

// MARK: - Implementation
final class MapKitDirectionsService: DirectionsServiceProtocol {
    
    func calculateTravelTime(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType
    ) async throws -> TimeInterval {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = transportType
        
        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        
        // Get the first route's travel time
        guard let route = response.routes.first else {
            throw DirectionsError.noRouteFound
        }
        
        return route.expectedTravelTime // in seconds
    }
    
    func calculateAllTravelTimes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async -> (car: TimeInterval?, transit: TimeInterval?, walk: TimeInterval?) {
        var carTime: TimeInterval?
        var transitTime: TimeInterval?
        var walkTime: TimeInterval?
        
        // Calculate car time
        if let time = try? await calculateTravelTime(from: origin, to: destination, transportType: .automobile) {
            carTime = time
            Logger.log(.function, level: .info, "Car time calculated: \(time)s")
        } else {
            Logger.log(.function, level: .warning, "Could not calculate car time")
        }
        
        // Calculate transit time
        if let time = try? await calculateTravelTime(from: origin, to: destination, transportType: .transit) {
            transitTime = time
            Logger.log(.function, level: .info, "Transit time calculated: \(time)s")
        } else {
            Logger.log(.function, level: .warning, "Could not calculate transit time")
        }
        
        // Calculate walking time (only for reasonable distances)
        let directDistance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        
        if directDistance <= 10000 { // Only calculate walk for distances <= 10km
            if let time = try? await calculateTravelTime(from: origin, to: destination, transportType: .walking) {
                walkTime = time
                Logger.log(.function, level: .info, "Walk time calculated: \(time)s")
            } else {
                Logger.log(.function, level: .warning, "Could not calculate walk time")
            }
        }
        
        return (carTime, transitTime, walkTime)
    }
}

// MARK: - Mock Directions Service
final class MockDirectionsService: DirectionsServiceProtocol {
    func calculateTravelTime(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        transportType: MKDirectionsTransportType
    ) async throws -> TimeInterval {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Calculate mock times based on distance
        let distance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        
        let distanceInKm = distance / 1000.0
        
        switch transportType {
        case .automobile:
            // ~60 km/h
            return distanceInKm / 60.0 * 3600 + Double.random(in: 300...600)
        case .transit:
            // ~30 km/h
            return distanceInKm / 30.0 * 3600 + Double.random(in: 600...1200)
        case .walking:
            // ~5 km/h
            return distanceInKm / 5.0 * 3600
        default:
            return distanceInKm / 60.0 * 3600
        }
    }
    
    func calculateAllTravelTimes(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async -> (car: TimeInterval?, transit: TimeInterval?, walk: TimeInterval?) {
        let distance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
            .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
        
        let distanceInKm = distance / 1000.0
        
        let carTime = distanceInKm / 60.0 * 3600 + Double.random(in: 300...600)
        let transitTime = distanceInKm / 30.0 * 3600 + Double.random(in: 600...1200)
        let walkTime = distanceInKm <= 10 ? distanceInKm / 5.0 * 3600 : nil
        
        // Simulate async delay
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        return (carTime, transitTime, walkTime)
    }
}

// MARK: - Errors
enum DirectionsError: LocalizedError {
    case noRouteFound
    case invalidCoordinates
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .noRouteFound:
            return "No route found between locations"
        case .invalidCoordinates:
            return "Invalid coordinates provided"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        }
    }
}

