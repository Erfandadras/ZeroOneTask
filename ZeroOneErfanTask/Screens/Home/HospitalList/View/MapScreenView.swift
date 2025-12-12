//
//  ContentView.swift
//  ZeroOneErfanTest
//
//  Created by Erfan mac mini on 12/11/25.
//

import SwiftUI
import MapKit
import BaseModule

struct MapScreenView: View {
    // MARK: - Properties
    @State private var viewModel: MapScreenVM
    @State private var cameraPosition: MapCameraPosition
    @State private var offset: CGFloat = K.size.portrait.width
    @State private var dragOffset: CGFloat = 0
    @Namespace var namespace
    
    let centerCoordinate: CLLocationCoordinate2D
    let searchRadius: CLLocationDistance = 20000 // 20km
    @State private var selectedHospital: HospitalUIItem?
    
    // MARK: - Offset Stages
    private var offsetStages: [CGFloat] {
        [0, K.size.portrait.width / 2, K.size.portrait.width]
    }
    
    // MARK: - init
    init(
        latitude: CLLocationDegrees = 43.82,
        longitude: CLLocationDegrees = -79.34,
        searchService: HospitalSearchServiceProtocol = MapKitHospitalSearchService()
    ) {
        self.centerCoordinate = CLLocationCoordinate2D(latitude: latitude,
                                                       longitude: longitude)
        
        // Initialize camera position
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude,
                                               longitude: longitude),
                latitudinalMeters: 40000, // Show 40km to see the full 20km radius
                longitudinalMeters: 40000
            )
        ))
        
        // Initialize ViewModel with dependency injection
        _viewModel = State(initialValue: MapScreenVM(searchService: searchService))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // Map Section
                Map(position: $cameraPosition,
                    bounds: .init(minimumDistance: 1000,
                                  maximumDistance: 500000),
                    interactionModes: .all, scope: namespace) {
                    // Center marker
                    Annotation("Center", coordinate: centerCoordinate) {
                        ZStack {
                            Circle()
                                .fill(.ui.blue.opacity(0.3))
                                .frame(width: 20, height: 20)
                            Circle()
                                .fill(.ui.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    // Hospital markers
                    ForEach(viewModel.hospitalUIItems) { hospital in
                        let selected = selectedHospital?.id == hospital.id
                        Annotation(hospital.name, coordinate: hospital.coordinate) {
                            Button(action: {
                                selectedHospital = hospital
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("H")
                                            .font(Font.Poppins.semiBold(24))
                                            .foregroundStyle(.ui.white)
                                            .frame(width: 32)
                                            .background(hospital.availability ? .ui.red : .ui.gray)
                                            .clipShape(.circle)
                                    }
                                    
                                    if selected {
                                        HStack(spacing: 0){
                                            VStack(spacing: 2) {
                                                Text(hospital.distanceInKm)
                                                    .font(.ui.xsRegular)
                                                Text("KM")
                                                    .font(.ui.xsRegular)
                                            }
                                            .foregroundStyle(.ui.red)
                                            .padding(.horizontal, 8)
                                            
                                            VStack(spacing: 2) {
                                                Text(hospital.waitingTimeStr)
                                                    .font(.ui.xsRegular)
                                                Text("Waiting Time")
                                                    .font(Font.Poppins.regular(8))
                                            }
                                            .foregroundStyle(.ui.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(.ui.red)
                                        }
                                        .background(.ui.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }.zIndex(selected ? 1000 : 1)
                        }
                    }
                    
                    // 20km radius circle
                    MapCircle(center: centerCoordinate, radius: searchRadius)
                        .foregroundStyle(.ui.blue.opacity(0.1))
                        .stroke(.ui.blue, lineWidth: 2)
                }
                    .cornerRadius(20, corners: .allCorners)
                    .frame(height: K.size.portrait.width, alignment: .center)
                    .padding(.horizontal, defaultHPadding)
                Spacer()
            }
            // Hospital List Section
            HospitalListView(selected: $viewModel.selectedSegment,
                             loading: viewModel.isLoading,
                             hospitals: viewModel.sortedHospitals,
                             selectedItem: selectedHospital,
                             offset: offset) { hospital in
                // Show detail immediately (fast presentation)
                selectedHospital = hospital
            }
            .offset(y: offset + dragOffset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        // Update drag offset, but constrain it
                        let translation = value.translation.height
                        
                        // final position
                        let finalPosition = offset + translation
                        
                        
                        if finalPosition > 0 && finalPosition <= (K.size.portrait.width + 45) { // extra debounce
                            dragOffset = translation
                        }
                    }
                    .onEnded { value in
                        // Calculate final position
                        let finalPosition = offset + dragOffset
                        
                        // Find the nearest stage
                        let nearestStage = findNearestStage(to: finalPosition)
                        
                        // Animate to the nearest stage
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = nearestStage
                            dragOffset = 0
                        }
                    }
            ).disabled(viewModel.isLoading || viewModel.errorMessage != nil)
                .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationTitle("Find Hospital")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search hospitals")
        .onSubmit(of: .search) {
            viewModel.searchHospitalsByName(query: viewModel.searchText,
                                            near: centerCoordinate,
                                            radius: searchRadius)
        }
        .onChange(of: selectedHospital, { _, hospital in
            // Animate camera to hospital location
            withAnimation {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: hospital?.coordinate ?? centerCoordinate,
                        latitudinalMeters: hospital != nil ? 2000 : 40000,
                        longitudinalMeters: hospital != nil ? 2000 : 40000
                    )
                )
            }
        })
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            if newValue.isEmpty {
                viewModel.searchHospitals(near: centerCoordinate, radius: searchRadius)
            }
        }
        .task {
            // Load hospitals when view appears
            viewModel.searchHospitals(near: centerCoordinate, radius: searchRadius)
        }
        .sheet(item: $selectedHospital) { hospital in
            HospitalDetailView(
                hospital: hospital,
                viewModel: viewModel,
                originCoordinate: centerCoordinate
            )
        }
    }
    
    // MARK: - Helper Methods
    private func findNearestStage(to position: CGFloat) -> CGFloat {
        // Find the stage with minimum distance to current position
        offsetStages.min(by: { abs($0 - position) < abs($1 - position) }) ?? offsetStages[1]
    }
}
