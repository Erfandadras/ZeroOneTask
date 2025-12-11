//
//  Hospital.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import Foundation
import MapKit

// MARK: - Hospital Model
struct Hospital: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: Double // in meters
    let phoneNumber: String?
    
    // Real travel time data (calculated via MKDirections)
    var carArrivalDuration: TimeInterval? // in seconds
    var transitArrivalDuration: TimeInterval? // in seconds (bus/metro)
    var walkArrivalDuration: TimeInterval? // in seconds
    
    // Mock data fields (until real API is available)
    var availability: Bool
    var latestUpdate: Date?
    var waitingTime: Int? // in minutes
    var rating: Double?
    
    var distanceInKm: String {
        String(format: "%.2f km", distance / 1000)
    }
}

// MARK: - UIModel
enum HospitalListSegment: String, CaseIterable {
    case nearby
    case early
    
    var title: String {
        switch self {
        case .nearby:
            "Nearest"
        case .early:
            "Earliest"
        }
    }
}

struct HospitalUIItem: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: Double // in meters
    let phoneNumber: String?
    var availability: Bool
    var latestUpdate: Date?
    var waitingTime: String?
    var carArrivalDuration: String?
    var busArrivalDuration: String?
    var walkArrivalDuration: String?
    var rating: Double?
    
    var distanceInKm: String {
        String(distance / 1000)
    }
    
    var lastUpdatedText: String {
        guard let date = latestUpdate else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var hasRating: Bool {
        rating != nil
    }
    
    init(from hospital: Hospital) {
        self.id = hospital.id
        self.name = hospital.name
        self.coordinate = hospital.coordinate
        self.address = hospital.address
        self.distance = hospital.distance
        self.phoneNumber = hospital.phoneNumber
        
        // Use data from Hospital model
        self.availability = hospital.availability
        self.latestUpdate = hospital.latestUpdate
        self.rating = hospital.rating
        
        // Format waiting time
        if let waitTime = hospital.waitingTime, hospital.availability {
            self.waitingTime = "\(waitTime) min"
        } else {
            self.waitingTime = "N/A"
        }
        
        // Format car arrival duration
        if let carTime = hospital.carArrivalDuration {
            self.carArrivalDuration = Self.formatDuration(seconds: carTime)
        } else {
            self.carArrivalDuration = nil
        }
        
        // Format transit (bus) arrival duration
        if let transitTime = hospital.transitArrivalDuration {
            self.busArrivalDuration = Self.formatDuration(seconds: transitTime)
        } else {
            self.busArrivalDuration = nil
        }
        
        // Format walk arrival duration
        if let walkTime = hospital.walkArrivalDuration {
            self.walkArrivalDuration = Self.formatDuration(seconds: walkTime)
        } else {
            self.walkArrivalDuration = nil
        }
    }
    
    private static func formatDuration(seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
}
