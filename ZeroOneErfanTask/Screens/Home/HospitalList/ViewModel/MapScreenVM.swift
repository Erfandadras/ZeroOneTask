//
//  MapScreenVM.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import Foundation
import MapKit
import SwiftUI
import Combine
import BaseModule

@Observable
class MapScreenVM {
    // MARK: - Properties
    var hospitals: [Hospital] = []
    var hospitalUIItems: [HospitalUIItem] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var searchText: String = ""
    var selectedSegment: HospitalListSegment = .early
    var isFetchingTravelData: Bool = false
    
    private let searchService: HospitalSearchServiceProtocol
    private let directionsService: DirectionsServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var travelDataCache: [UUID: (car: TimeInterval?, transit: TimeInterval?, walk: TimeInterval?)] = [:]
    
    // Computed property for sorted hospitals
    var sortedHospitals: [HospitalUIItem] {
        switch selectedSegment {
        case .nearby:
            return hospitalUIItems.sorted { $0.distance < $1.distance }
        case .early:
            return hospitalUIItems.sorted { hospital1, hospital2 in
                // First, prioritize available hospitals
                if hospital1.availability != hospital2.availability {
                    return hospital1.availability && !hospital2.availability
                }
                
                guard let time1 = hospital1.waitingTime, let time2 = hospital2.waitingTime else {
                    return false
                }
                // For unavailable hospitals, sort by distance
                return time1 < time2
            }
        }
    }
    
    // MARK: - Initialization
    init(searchService: HospitalSearchServiceProtocol,
         directionsService: DirectionsServiceProtocol = MapKitDirectionsService()) {
        self.searchService = searchService
        self.directionsService = directionsService
    }
    
    // MARK: - Public Methods
    func searchHospitals(near coordinate: CLLocationCoordinate2D,
                         radius: CLLocationDistance) {
        // Cancel previous search
        searchTask?.cancel()
        
        searchTask = Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let foundHospitals = try await searchService.searchHospitals(
                    near: coordinate,
                    radius: radius
                )
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.hospitals = foundHospitals
                    self.hospitalUIItems = foundHospitals.map { HospitalUIItem(from: $0) }
                    self.isLoading = false
                }
            } catch {
                Logger.log(.function, level: .error, error.localizedDescription)
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    if let mkError = error as? MKError, mkError.code == .placemarkNotFound {
                        self.errorMessage = "No hospitals found in this area. Try increasing the search radius."
                        self.hospitals = []
                        self.hospitalUIItems = []
                    } else {
                        self.errorMessage = "Failed to search hospitals: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchHospitalsByName(query: String,
                               near coordinate: CLLocationCoordinate2D,
                               radius: CLLocationDistance) {
        // Cancel previous search
        searchTask?.cancel()
        
        searchTask = Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            do {
                let foundHospitals = try await searchService.searchHospitals(
                    query: query,
                    near: coordinate,
                    radius: radius
                )
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.hospitals = foundHospitals
                    self.hospitalUIItems = foundHospitals.map { HospitalUIItem(from: $0) }
                    self.isLoading = false
                }
            } catch {
                Logger.log(.function, level: .error, error.localizedDescription)
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    if let mkError = error as? MKError, mkError.code == .placemarkNotFound {
                        self.errorMessage = "No hospitals found in this area. Try increasing the search radius."
                        self.hospitals = []
                        self.hospitalUIItems = []
                    } else {
                        self.errorMessage = "Failed to search hospitals: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Travel Data Fetching
    
    /// Fetches travel data for a specific hospital and updates the UI item
    /// - Parameters:
    ///   - hospital: The hospital UI item to fetch travel data for
    ///   - origin: The origin coordinate (user's location or search center)
    /// - Returns: Updated hospital UI item with travel data
    func fetchTravelDataForHospital(_ hospital: HospitalUIItem, from origin: CLLocationCoordinate2D) async -> HospitalUIItem {
        // Check cache first
        if let cached = travelDataCache[hospital.id] {
            Logger.log(.function, level: .info, "Using cached travel data for \(hospital.name)")
            return updateHospitalWithTravelData(hospital, travelData: cached)
        }
        
        // Fetch travel data
        await MainActor.run {
            self.isFetchingTravelData = true
        }
        
        Logger.log(.function, level: .info, "Fetching travel data for \(hospital.name)")
        
        let travelData = await directionsService.calculateAllTravelTimes(
            from: origin,
            to: hospital.coordinate
        )
        
        // Cache the result
        await MainActor.run {
            self.travelDataCache[hospital.id] = travelData
            self.isFetchingTravelData = false
        }
        
        // Update the hospital in the array
        let updatedHospital = updateHospitalWithTravelData(hospital, travelData: travelData)
        
        await MainActor.run {
            // Find and update the hospital in the array
            if let index = self.hospitalUIItems.firstIndex(where: { $0.id == hospital.id }) {
                self.hospitalUIItems[index] = updatedHospital
            }
            
            // Also update the corresponding Hospital model
            if let hospitalIndex = self.hospitals.firstIndex(where: { $0.id == hospital.id }) {
                self.hospitals[hospitalIndex].carArrivalDuration = travelData.car
                self.hospitals[hospitalIndex].transitArrivalDuration = travelData.transit
                self.hospitals[hospitalIndex].walkArrivalDuration = travelData.walk
            }
        }
        
        return updatedHospital
    }
    
    private func updateHospitalWithTravelData(
        _ hospital: HospitalUIItem,
        travelData: (car: TimeInterval?, transit: TimeInterval?, walk: TimeInterval?)
    ) -> HospitalUIItem {
        return HospitalUIItem(
            id: hospital.id,
            name: hospital.name,
            coordinate: hospital.coordinate,
            address: hospital.address,
            distance: hospital.distance,
            phoneNumber: hospital.phoneNumber,
            availability: hospital.availability,
            latestUpdate: hospital.latestUpdate,
            waitingTime: hospital.waitingTime,
            carArrivalDuration: travelData.car.map { HospitalUIItem.formatDuration(seconds: $0) },
            busArrivalDuration: travelData.transit.map { HospitalUIItem.formatDuration(seconds: $0) },
            walkArrivalDuration: travelData.walk.map { HospitalUIItem.formatDuration(seconds: $0) },
            rating: hospital.rating
        )
    }
    
    // MARK: - Cleanup
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Helper Methods
    private func parseWaitingTimeMinutes(from waitingTimeString: String) -> Int {
        // Extract the first number from the waiting time string
        // Examples: "25 min waiting time" -> 25, "2 hrs 25 min waiting time" -> 145
        
        let components = waitingTimeString.components(separatedBy: " ")
        var totalMinutes = 0
        
        for i in 0..<components.count {
            if let value = Int(components[i]) {
                let nextComponent = i + 1 < components.count ? components[i + 1] : ""
                
                if nextComponent.contains("day") {
                    totalMinutes += value * 24 * 60
                } else if nextComponent.contains("hr") {
                    totalMinutes += value * 60
                } else if nextComponent.contains("min") {
                    totalMinutes += value
                }
            }
        }
        
        return totalMinutes > 0 ? totalMinutes : Int.max // Return max for N/A or invalid
    }
}

