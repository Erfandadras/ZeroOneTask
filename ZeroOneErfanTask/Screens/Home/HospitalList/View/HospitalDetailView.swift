//
//  HospitalDetailView.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/12/25.
//

import SwiftUI
import BaseModule
import CoreLocation

struct HospitalDetailView: View {
    // MARK: - properties
    let hospital: HospitalUIItem
    let viewModel: MapScreenVM
    let originCoordinate: CLLocationCoordinate2D
    
    @State private var updatedHospital: HospitalUIItem?
    @State private var isFetchingData: Bool = false
    @Environment(\.safeAreaInsets) private var insets
    @State private var maxHeight: CGFloat = 50
    
    // Use updated hospital if available, otherwise use original
    private var displayHospital: HospitalUIItem {
        updatedHospital ?? hospital
    }
    // MARK: - view
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom) {
                VStack {
                    // first row
                    HStack {
                        HStack {
                            Image(systemName: "pentagon")
                            Text("Multi-Speciality")
                                .font(.ui.sSemiBold)
                        }
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(8, corners: .allCorners)
                        
                        Spacer()
                        
                        Text(displayHospital.lastUpdatedText)
                            .font(.ui.sRegular)
                            .foregroundStyle(.secondary)
                    }
                    // second row
                    HStack{
                        Circle()
                            .fill(displayHospital.availability ? .blue : .red)
                            .frame(width: 20)
                        Text(displayHospital.name)
                            .font(.ui.mSemiBold)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        
                        Text(String(format: "%.1f", displayHospital.rating))
                            .font(.ui.mRegular)
                            .foregroundStyle(.primary)
                    }
                    
                    // third row
                    HStack {
                        Image(systemName: "clock")
                        Text(displayHospital.waitingTimeStr + " waiting time")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                    
                    // 4th row
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(displayHospital.distanceInKm + " Km")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                    
                    // 4th row
                    HStack {
                        Image(systemName: "p.circle")
                        Text(displayHospital.availability ? "Available" : "Not Available")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                    
                    // 5th row - Travel times
                    HStack(spacing: 0){
                        if isFetchingData {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 8)
                            Text("Calculating routes...")
                                .font(.ui.sRegular)
                                .foregroundStyle(.secondary)
                        } else {
                            if let carArrivalDuration = displayHospital.carArrivalDuration {
                                Image(systemName: "car")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                Text(carArrivalDuration)
                                    .font(.ui.mRegular)
                                    .padding(.leading, 4)
                            }
                            
                            if let busArrivalDuration = displayHospital.busArrivalDuration {
                                Image(systemName: "bus.doubledecker.fill")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .padding(.leading, 8)
                                Text(busArrivalDuration)
                                    .font(.ui.mRegular)
                                    .padding(.leading, 4)
                            }
                            
                            if let walkArrivalDuration = displayHospital.walkArrivalDuration {
                                Image(systemName: "figure.walk")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .padding(.leading, 8)
                                Text(walkArrivalDuration)
                                    .font(.ui.mRegular)
                                    .padding(.leading, 4)
                            }
                        }
                        Spacer()
                    }
                    .foregroundStyle(.primary)
                }
                // Vstack
                .padding(.horizontal, 12.updateForHeight())
                .padding(.bottom, insets.bottom)
                .padding(.top, 32.updateForHeight())
            }// ZStack
            .sizeChangePrefenece { size in
                maxHeight = size.height
            }
        }// ScrollView
        .background(.white)
        .cornerRadius(20.updateForHeight(), corners: [.topLeft, .topRight])
        .background(BackgroundClearView())
        .ignoresSafeArea(.all)
        .presentationDetents(maxHeight <= 50 ? [.height(50)] : [.height(maxHeight - insets.bottom)])
        .task {
            // Fetch travel data when view appears
            await fetchTravelData()
        }
    }
    
    // MARK: - Helper Methods
    private func fetchTravelData() async {
        // Set loading state
        isFetchingData = true
        
        // Fetch travel data
        let updated = await viewModel.fetchTravelDataForHospital(hospital, from: originCoordinate)
        
        // Update the displayed hospital
        updatedHospital = updated
        isFetchingData = false
    }
}
