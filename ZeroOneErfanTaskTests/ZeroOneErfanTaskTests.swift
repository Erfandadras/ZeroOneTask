//
//  ZeroOneErfanTaskTests.swift
//  ZeroOneErfanTaskTests
//
//  Created by Erfan mac mini on 12/12/25.
//

import Testing
import Foundation
import MapKit
@testable import ZeroOneErfanTask

// MARK: - Hospital Model Tests
@Suite("Hospital Model Tests")
struct HospitalModelTests {
    
    @Test("Hospital initializes with correct properties")
    func testHospitalInitialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 43.6596, longitude: -79.3876)
        
        let hospital = Hospital(
            name: "Test Hospital",
            coordinate: coordinate,
            address: "123 Test St",
            distance: 5000,
            phoneNumber: "+1234567890",
            carArrivalDuration: 600,
            transitArrivalDuration: 1200,
            walkArrivalDuration: 3600,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 30,
            rating: 4.5
        )
        
        #expect(hospital.name == "Test Hospital")
        #expect(hospital.coordinate.latitude == 43.6596)
        #expect(hospital.coordinate.longitude == -79.3876)
        #expect(hospital.distance == 5000)
        #expect(hospital.availability == true)
        #expect(hospital.waitingTime == 30)
        #expect(hospital.rating == 4.5)
    }
    
    @Test("Hospital distance formatting is correct")
    func testDistanceFormatting() {
        let hospital = Hospital(
            name: "Test",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            address: "",
            distance: 5200,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: nil,
            waitingTime: nil,
            rating: nil
        )
        
        #expect(hospital.distanceInKm == "5.20 km")
    }
}

// MARK: - HospitalUIItem Tests
@Suite("HospitalUIItem Tests")
@MainActor
struct HospitalUIItemTests {
    
    @Test("HospitalUIItem converts from Hospital correctly")
    func testHospitalUIItemConversion() {
        let coordinate = CLLocationCoordinate2D(latitude: 43.6596, longitude: -79.3876)
        let hospital = Hospital(
            name: "Toronto General",
            coordinate: coordinate,
            address: "200 Elizabeth St",
            distance: 5200,
            phoneNumber: "+14163404800",
            carArrivalDuration: 720,  // 12 minutes
            transitArrivalDuration: 1680, // 28 minutes
            walkArrivalDuration: 3900, // 65 minutes
            availability: true,
            latestUpdate: Date(),
            waitingTime: 25,
            rating: 4.5
        )
        
        let uiItem = HospitalUIItem(from: hospital)
        
        #expect(uiItem.name == "Toronto General")
        #expect(uiItem.availability == true)
        #expect(uiItem.rating == 4.5)
        #expect(uiItem.carArrivalDuration != nil)
        #expect(uiItem.busArrivalDuration != nil)
        #expect(uiItem.walkArrivalDuration != nil)
    }
    
    @Test("Waiting time formatting with different values")
    func testWaitingTimeFormatting() async throws {
        // Test short wait
        let shortWait = HospitalUIItem.formatWaitingTime(minutes: 25)
        #expect(shortWait == "25 min")
        
        // Test hours and minutes
        let hoursAndMinutes = HospitalUIItem.formatWaitingTime(minutes: 145)
        #expect(hoursAndMinutes == "2 hrs 25 min")
        
        // Test exact hours
        let exactHours = HospitalUIItem.formatWaitingTime(minutes: 120)
        #expect(exactHours == "2 hrs")
        
        // Test days
        let days = HospitalUIItem.formatWaitingTime(minutes: 1440)
        #expect(days == "1 day")
        
        // Test complex
        let complex = HospitalUIItem.formatWaitingTime(minutes: 1500)
        #expect(complex == "1 day 1 hr")
        
        // Test zero
        let zero = HospitalUIItem.formatWaitingTime(minutes: 0)
        #expect(zero == "0 min")
    }
    
    @Test("Duration formatting from seconds")
    func testDurationFormatting() {
        // Test minutes
        let minutes = HospitalUIItem.formatDuration(seconds: 600)
        #expect(minutes == "10 min")
        
        // Test hours and minutes
        let hoursMinutes = HospitalUIItem.formatDuration(seconds: 5400)
        #expect(hoursMinutes == "1h 30m")
        
        // Test exact hours
        let hours = HospitalUIItem.formatDuration(seconds: 7200)
        #expect(hours == "2h")
    }
}

// MARK: - Mock Service Tests
@Suite("Mock Hospital Search Service Tests")
@MainActor
struct MockHospitalSearchServiceTests {
    
    @Test("Mock service returns empty array by default")
    func testMockServiceEmpty() async throws {
        let mockService = MockHospitalSearchService()
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        
        let results = try await mockService.searchHospitals(near: coordinate, radius: 20000)
        
        #expect(results.isEmpty)
    }
    
    @Test("Mock service returns provided hospitals")
    func testMockServiceWithData() async throws {
        let mockService = MockHospitalSearchService()
        
        let testHospital = Hospital(
            name: "Test Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34),
            address: "Test Address",
            distance: 1000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: nil,
            waitingTime: 20,
            rating: 4.0
        )
        
        mockService.mockHospitals = [testHospital]
        
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        let results = try await mockService.searchHospitals(near: coordinate, radius: 20000)
        
        #expect(results.count == 1)
        #expect(results.first?.name == "Test Hospital")
    }
    
    @Test("Mock service throws error when configured")
    func testMockServiceThrowsError() async throws {
        let mockService = MockHospitalSearchService()
        mockService.shouldThrowError = true
        
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        
        await #expect(throws: Error.self) {
            try await mockService.searchHospitals(near: coordinate, radius: 20000)
        }
    }
    
    @Test("Mock service filters by query")
    func testMockServiceQueryFiltering() async throws {
        let mockService = MockHospitalSearchService()
        
        let hospital1 = Hospital(
            name: "General Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34),
            address: "Address 1",
            distance: 1000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: nil,
            waitingTime: 20,
            rating: 4.0
        )
        
        let hospital2 = Hospital(
            name: "Children Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.83, longitude: -79.35),
            address: "Address 2",
            distance: 2000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: nil,
            waitingTime: 30,
            rating: 4.5
        )
        
        mockService.mockHospitals = [hospital1, hospital2]
        
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        let results = try await mockService.searchHospitals(
            query: "General",
            near: coordinate,
            radius: 20000
        )
        
        #expect(results.count == 1)
        #expect(results.first?.name == "General Hospital")
    }
}

// MARK: - ViewModel Tests
@Suite("MapScreenVM Tests")
@MainActor
struct MapScreenVMTests {
    
    @Test("ViewModel initializes with empty state")
    func testViewModelInitialization() {
        let mockService = MockHospitalSearchService()
        let viewModel = MapScreenVM(searchService: mockService)
        
        #expect(viewModel.hospitals.isEmpty)
        #expect(viewModel.hospitalUIItems.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.searchText == "")
        #expect(viewModel.selectedSegment == .early)
    }
    
    @Test("ViewModel loads hospitals successfully")
    func testViewModelLoadHospitals() async throws {
        let mockService = MockHospitalSearchService()
        
        let testHospital = Hospital(
            name: "Test Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34),
            address: "Test Address",
            distance: 5000,
            phoneNumber: nil,
            carArrivalDuration: 600,
            transitArrivalDuration: 1200,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 25,
            rating: 4.5
        )
        
        mockService.mockHospitals = [testHospital]
        
        let viewModel = MapScreenVM(searchService: mockService)
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        
        viewModel.searchHospitals(near: coordinate, radius: 20000)
        
        // Wait for async operations
        try await Task.sleep(nanoseconds: 700_000_000) // 0.7 seconds
        
        #expect(viewModel.hospitals.count == 1)
        #expect(viewModel.hospitalUIItems.count == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hospitalUIItems.first?.name == "Test Hospital")
    }
    
    @Test("ViewModel sorts hospitals by distance (nearby)")
    func testViewModelSortsByDistance() async throws {
        let mockService = MockHospitalSearchService()
        
        let farHospital = Hospital(
            name: "Far Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34),
            address: "Far Address",
            distance: 10000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 30,
            rating: 4.0
        )
        
        let nearHospital = Hospital(
            name: "Near Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.83, longitude: -79.35),
            address: "Near Address",
            distance: 2000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 45,
            rating: 4.5
        )
        
        mockService.mockHospitals = [farHospital, nearHospital]
        
        let viewModel = MapScreenVM(searchService: mockService)
        await MainActor.run {
            viewModel.selectedSegment = .nearby
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        viewModel.searchHospitals(near: coordinate, radius: 20000)
        
        try await Task.sleep(nanoseconds: 600_000_000)
        
        let sorted = await MainActor.run {
            viewModel.sortedHospitals
        }
        #expect(sorted.count == 2)
        #expect(sorted.first?.name == "Near Hospital")
        #expect(sorted.last?.name == "Far Hospital")
    }
    
    @Test("ViewModel sorts hospitals by waiting time (early)")
    func testViewModelSortsByWaitingTime() async throws {
        let mockService = MockHospitalSearchService()
        
        let longWait = Hospital(
            name: "Long Wait Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34),
            address: "Address 1",
            distance: 5000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 60,
            rating: 4.0
        )
        
        let shortWait = Hospital(
            name: "Short Wait Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 43.83, longitude: -79.35),
            address: "Address 2",
            distance: 8000,
            phoneNumber: nil,
            carArrivalDuration: nil,
            transitArrivalDuration: nil,
            walkArrivalDuration: nil,
            availability: true,
            latestUpdate: Date(),
            waitingTime: 20,
            rating: 4.5
        )
        
        mockService.mockHospitals = [longWait, shortWait]
        
        let viewModel = MapScreenVM(searchService: mockService)
        await MainActor.run {
            viewModel.selectedSegment = .early
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        viewModel.searchHospitals(near: coordinate, radius: 20000)
        
        try await Task.sleep(nanoseconds: 600_000_000)
        
        let sorted = await MainActor.run {
            viewModel.sortedHospitals
        }
        #expect(sorted.count == 2)
        #expect(sorted.first?.name == "Short Wait Hospital")
        #expect(sorted.last?.name == "Long Wait Hospital")
    }
}

// MARK: - Mock Directions Service Tests
@Suite("Mock Directions Service Tests")
@MainActor
struct MockDirectionsServiceTests {
    
    @Test("Mock directions service calculates car time")
    func testCarTravelTime() async throws {
        let mockService = MockDirectionsService()
        let origin = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        let destination = CLLocationCoordinate2D(latitude: 43.83, longitude: -79.35)
        
        let carTime = try await mockService.calculateTravelTime(
            from: origin,
            to: destination,
            transportType: .automobile
        )
        
        #expect(carTime > 0)
    }
    
    @Test("Mock directions service calculates all travel times")
    func testAllTravelTimes() async throws {
        let mockService = MockDirectionsService()
        let origin = CLLocationCoordinate2D(latitude: 43.82, longitude: -79.34)
        let destination = CLLocationCoordinate2D(latitude: 43.83, longitude: -79.35)
        
        let times = await mockService.calculateAllTravelTimes(from: origin, to: destination)
        
        #expect(times.car != nil)
        #expect(times.transit != nil)
        // Walk might be nil for far distances
    }
}

