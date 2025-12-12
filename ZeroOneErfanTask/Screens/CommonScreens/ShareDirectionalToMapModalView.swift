//
//  ShareDirectionalToMapModalView.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/12/25.
//

import SwiftUI
import BaseModule
import CoreLocation

enum MapDestinations: CaseIterable {
    case maps
    case googleMaps
    case waze
    
    var title: String {
        switch self {
        case .maps:
            return "open in Maps"
        case .googleMaps:
            return "open in Google Maps"
        case .waze:
            return "open in Waze"
        }
    }
}
struct ShareDirectionalToMapModalView: View {
    @Environment(\.safeAreaInsets) private var insets
    @Environment(\.dismiss) private var dismiss
    @State private var maxHeight: CGFloat = 50
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let transportTypes: TransportType
    let destination: CLLocationCoordinate2D
    let destinationName: String?
    
    init(transportTypes: TransportType, 
         destination: CLLocationCoordinate2D,
         destinationName: String? = nil) {
        self.transportTypes = transportTypes
        self.destination = destination
        self.destinationName = destinationName
    }
    
    // MARK: - View
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom){
                VStack {
                    HStack {
                        Color.clear
                            .frame(width: 32)
                        Spacer()
                        Text("Select an action")
                            .font(.ui.mSemiBold)
                            .foregroundStyle(.ui.textPrimary)
                        Spacer()
                        Button{
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.ui.red)
                                .padding(4)
                        }
                        
                    }
                    
                    VStack(alignment: .leading){
                        ForEach(MapDestinations.allCases.indices,
                                id: \.self) { index in
                            let mapDestination = MapDestinations.allCases[index]
                            Button{
                                handleMapSelection(mapDestination)
                            } label: {
                                Text(mapDestination.title)
                                    .font(.ui.mRegular)
                                    .foregroundColor(.ui.textPrimary)
                                .padding(.vertical)
                            }// button
                            .leading()
                            if index != MapDestinations.allCases.count - 1 {
                                Divider()
                                    .frame(height: 1)
                                    .background(.ui.textPrimary)
                            }
                        }// for each
                                .padding(.horizontal, 12)
                    }// VStack
                    .addBorder(with: 20, color: .ui.textPrimary, width: 1)
                    .padding(.top, 20)
                }// VStack
                .padding(.horizontal, 12.updateForHeight())
                .padding(.bottom, insets.bottom)
                .padding(.top, 32.updateForHeight())
            }//ZStack
            .sizeChangePrefenece { size in
                maxHeight = size.height
            }
        }// ScrollView
        .background(.ui.white)
        .cornerRadius(20.updateForHeight(), corners: [.topLeft, .topRight])
        .background(BackgroundClearView())
        .ignoresSafeArea(.all)
        .presentationDetents(maxHeight <= 50 ? [.height(50)] : [.height(maxHeight - insets.bottom)])
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Helper Methods
    private func handleMapSelection(_ mapDestination: MapDestinations) {
        switch mapDestination {
        case .maps:
            MapDirectionsHelper.openInAppleMaps(
                destination: destination,
                transportType: transportTypes,
                destinationName: destinationName
            )
            dismiss()
            
        case .googleMaps:
            let success = MapDirectionsHelper.openInGoogleMaps(
                destination: destination,
                transportType: transportTypes
            )
            if success {
                dismiss()
            } else {
                alertMessage = "Unable to open Google Maps. Please install the app or try the web version."
                showAlert = true
            }
            
        case .waze:
            let success = MapDirectionsHelper.openInWaze(destination: destination)
            if success {
                dismiss()
            } else {
                alertMessage = "Unable to open Waze. Please install the app or try the web version."
                showAlert = true
            }
        }
    }
}
