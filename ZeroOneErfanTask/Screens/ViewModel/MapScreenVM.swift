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
    
    private let searchService: HospitalSearchServiceProtocol
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(searchService: HospitalSearchServiceProtocol) {
        self.searchService = searchService
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
    
    // MARK: - Cleanup
    deinit {
        searchTask?.cancel()
    }
}

