//
//  HospitalSearchService.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import Foundation
import MapKit

// MARK: - Protocol
protocol HospitalSearchServiceProtocol {
    func searchHospitals(
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital]
    
    func searchHospitals(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital]
}

// MARK: - Implementation
final class MapKitHospitalSearchService: HospitalSearchServiceProtocol {
    func searchHospitals(
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "hospital"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        request.resultTypes = [.pointOfInterest, .address]
        return try await performSearch(request: request,
                                       centerCoordinate: coordinate,
                                       radius: radius)
    }
    
    func searchHospitals(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query.isEmpty ? "hospital" : "\(query) hospital"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        request.resultTypes = .pointOfInterest
        
        return try await performSearch(request: request, centerCoordinate: coordinate, radius: radius)
    }
    
    // MARK: - Private Methods
    private func performSearch(
        request: MKLocalSearch.Request,
        centerCoordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital] {
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        let centerLocation = CLLocation(
            latitude: centerCoordinate.latitude,
            longitude: centerCoordinate.longitude
        )
        
        // First, create basic hospital objects
        return response.mapItems
            .compactMap { mapItem -> Hospital? in
                guard let location = mapItem.placemark.location else { return nil }
                
                let distance = centerLocation.distance(from: location)
                if distance > radius { return nil }
                // Generate mock data
                let availability = Double.random(in: 0...1) > 0.2
                let waitingTime = availability ? Int.random(in: 5...1200) : nil // in seconds
                let rating = Double.random(in: 1.0...5.0)
                let latestUpdate = Calendar.current.date(byAdding: .hour, value: -Int.random(in: 1...24), to: Date())
                
                return Hospital(
                    name: mapItem.name ?? "Unknown Hospital",
                    coordinate: mapItem.placemark.coordinate,
                    address: formatAddress(from: mapItem.placemark),
                    distance: distance,
                    phoneNumber: mapItem.phoneNumber,
                    carArrivalDuration: nil,
                    transitArrivalDuration: nil,
                    walkArrivalDuration: nil,
                    availability: availability,
                    latestUpdate: latestUpdate,
                    waitingTime: waitingTime,
                    rating: rating
                )
            }
            .sorted { $0.distance < $1.distance }
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        if let street = placemark.thoroughfare {
            addressComponents.append(street)
        }
        if let city = placemark.locality {
            addressComponents.append(city)
        }
        if let state = placemark.administrativeArea {
            addressComponents.append(state)
        }
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        return addressComponents.isEmpty ? "Address not available" : addressComponents.joined(separator: ", ")
    }
}

// MARK: - Mock Service for Testing/Preview
final class MockHospitalSearchService: HospitalSearchServiceProtocol {
    var mockHospitals: [Hospital] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "MockError", code: -1, userInfo: nil)
    
    func searchHospitals(
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        try await Task.sleep(nanoseconds: 500_000) // Simulate network delay
        return mockHospitals
    }
    
    func searchHospitals(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) async throws -> [Hospital] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        try await Task.sleep(nanoseconds: 500_000) // Simulate network delay
        
        if query.isEmpty {
            return mockHospitals
        }
        
        return mockHospitals.filter { hospital in
            hospital.name.localizedCaseInsensitiveContains(query)
        }
    }
}

