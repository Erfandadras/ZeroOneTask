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

struct HospitalUIItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: Double // in meters
    let phoneNumber: String?
    var availability: Bool
    var latestUpdate: Date?
    var waitingTime: Int?
    var carArrivalDuration: String?
    var busArrivalDuration: String?
    var walkArrivalDuration: String?
    var rating: Double
    var waitingTimeStr: String {
        if let waitTime = waitingTime, availability {
            Self.formatWaitingTime(minutes: waitTime)
        } else {
            "N/A"
        }
    }
    
    var distanceInKm: String {
        String(format: "%.1f", distance / 1000)
    }
    
    var lastUpdatedText: String {
        guard let date = latestUpdate else { return "Unknown" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Last updated " + formatter.localizedString(for: date, relativeTo: Date())
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
        self.rating = hospital.rating ?? 0
        waitingTime = hospital.waitingTime
        
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
    
    // MARK: - Formatting Helpers
    
    /// Formats waiting time from minutes to a readable string with days, hours, and minutes
    /// - Parameter minutes: The waiting time in minutes
    /// - Returns: Formatted string like "2 days 3 hrs 45 min" or "1 hr 30 min" or "45 min"
    static func formatWaitingTime(minutes: Int) -> String {
        guard minutes > 0 else { return "0 min" }
        
        let days = minutes / (24 * 60)
        let remainingAfterDays = minutes % (24 * 60)
        let hours = remainingAfterDays / 60
        let mins = remainingAfterDays % 60
        
        var components: [String] = []
        
        if days > 0 {
            components.append("\(days) \(days == 1 ? "day" : "days")")
        }
        
        if hours > 0 {
            components.append("\(hours) \(hours == 1 ? "hr" : "hrs")")
        }
        
        if mins > 0 || components.isEmpty {
            components.append("\(mins) min")
        }
        
        return components.joined(separator: " ")
    }
    
    static func formatDuration(seconds: TimeInterval) -> String {
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

// MARK: - Mock Data
extension HospitalUIItem {    
    // Single mock item for testing
    static var mockItem: HospitalUIItem {
        HospitalUIItem(
            id: UUID(),
            name: "Toronto General Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.6596, longitude: -79.3876),
            address: "200 Elizabeth St, Toronto, ON M5G 2C4, Canada",
            distance: 5200,
            phoneNumber: "+1 416-340-4800",
            availability: true,
            latestUpdate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            waitingTime: 1200,
            carArrivalDuration: "12 min",
            busArrivalDuration: "28 min",
            walkArrivalDuration: "1hr 5min",
            rating: 4.5
        )
    }
    
    // Direct initializer for convenience
    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        address: String,
        distance: Double,
        phoneNumber: String?,
        availability: Bool,
        latestUpdate: Date?,
        waitingTime: Int?,
        carArrivalDuration: String?,
        busArrivalDuration: String?,
        walkArrivalDuration: String?,
        rating: Double
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.distance = distance
        self.phoneNumber = phoneNumber
        self.availability = availability
        self.latestUpdate = latestUpdate
        self.waitingTime = waitingTime
        self.carArrivalDuration = carArrivalDuration
        self.busArrivalDuration = busArrivalDuration
        self.walkArrivalDuration = walkArrivalDuration
        self.rating = rating
    }
}

