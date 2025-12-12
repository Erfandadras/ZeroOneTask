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
    @State private var presentedDirectionType: Bool = false
    @State private var transportTypes: TransportType?
    
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
                        .foregroundStyle(.ui.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.ui.blue.opacity(0.2))
                        .cornerRadius(8, corners: .allCorners)
                        
                        Spacer()
                        
                        Text(displayHospital.lastUpdatedText)
                            .font(.ui.sRegular)
                            .foregroundStyle(.ui.textSecondary)
                    }
                    // second row
                    HStack{
                        Circle()
                            .fill(displayHospital.availability ? .ui.blue : .ui.red)
                            .frame(width: 20)
                        Text(displayHospital.name)
                            .font(.ui.mSemiBold)
                            .foregroundStyle(.ui.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(.ui.yellow)
                        
                        Text(String(format: "%.1f", displayHospital.rating))
                            .font(.ui.mRegular)
                            .foregroundStyle(.ui.textPrimary)
                    }
                    
                    // third row
                    HStack {
                        Image(systemName: "clock")
                        Text(displayHospital.waitingTimeStr + " waiting time")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.ui.textPrimary)
                    
                    // 4th row
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(displayHospital.distanceInKm + " Km")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.ui.textPrimary)
                    
                    // 4th row
                    HStack {
                        Image(systemName: "p.circle")
                        Text(displayHospital.availability ? "Available" : "Not Available")
                            .font(.ui.mRegular)
                        Spacer()
                    }
                    .foregroundStyle(.ui.textPrimary)
                    
                    // 5th row - Travel times
                    HStack(spacing: 0){
                        if isFetchingData {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 8)
                            
                            Text("Calculating routes...")
                                .font(.ui.sRegular)
                                .foregroundStyle(.ui.textSecondary)
                        } else {
                            if let carArrivalDuration = displayHospital.carArrivalDuration {
                                travelDirectionView(image: "car", value: carArrivalDuration)
                            }
                            
                            if let busArrivalDuration = displayHospital.busArrivalDuration {
                                travelDirectionView(image: "bus.doubledecker.fill", value: busArrivalDuration)
                            }
                            
                            if let walkArrivalDuration = displayHospital.walkArrivalDuration {
                                travelDirectionView(image: "figure.walk",
                                                    value: walkArrivalDuration)
                            }
                        }
                        Spacer()
                    }// Hstack
                    .foregroundStyle(.ui.textPrimary)
                    
                    Button {
                        presentedDirectionType = true
                    } label: {
                        Text("Get Direction")
                            .font(.ui.mRegular)
                            .foregroundStyle(.ui.white)
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16,
                                          backgroundColor: .ui.red)
                    }
                    .padding(.top, 20)
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
        .background(.ui.white)
        .cornerRadius(20.updateForHeight(), corners: [.topLeft, .topRight])
        .background(BackgroundClearView())
        .ignoresSafeArea(.all)
        .presentationDetents(maxHeight <= 50 ? [.height(50)] : [.height(maxHeight - insets.bottom)])
        .task {
            // Fetch travel data when view appears
            await fetchTravelData()
        }
        .sheet(isPresented: $presentedDirectionType) {
            GetDirectionModalView { type in
                transportTypes = type
            }
        }.sheet(item: $transportTypes, content: { type in
            ShareDirectionalToMapModalView(
                transportTypes: type,
                destination: hospital.coordinate,
                destinationName: hospital.name
            )
        })
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
    
    // MARK: - travel direction view
    @ViewBuilder
    private func travelDirectionView(image: String, value: String) -> some View {
        Image(systemName: image)
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundStyle(.ui.textPrimary)
        
        Text(value)
            .font(.ui.mRegular)
            .padding(.leading, 4)
            .foregroundStyle(.ui.textPrimary)
    }
}
