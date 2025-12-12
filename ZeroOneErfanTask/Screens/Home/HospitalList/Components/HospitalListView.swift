//
//  HospitalListView.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import SwiftUI
import BaseModule
import CoreLocation

// MARK: -  main content
struct HospitalListView: View {
    // MARK: - properties
    @Binding var selected: HospitalListSegment
    var loading: Bool
    var hospitals: [HospitalUIItem]
    var selectedItem: HospitalUIItem?
    var offset: CGFloat
    var onItemTapped: ((HospitalUIItem) -> Void)
    @Environment(\.safeAreaInsets) private var insets
    
    // MARK: - view
    var body: some View {
        VStack(spacing: 0){
            Color.ui.black.opacity(0.6)
                .frame(width: 80, height: 2)
                .cornerRadius(1)
                .padding(.vertical, 20)
            
            HStack(spacing: 0){
                segmentButton(type: .early,
                              selectedType: selected) {
                    withAnimation {
                        self.selected = .early
                    }
                }
                
                segmentButton(type: .nearby,
                              selectedType: selected) {
                    withAnimation {
                        self.selected = .nearby
                    }
                }
            }
            
            Group {
                if loading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .foregroundStyle(.ui.white)
                            .padding()
                        Spacer()
                    }
                } else {
                    if hospitals.isEmpty {
                        Text("No hospitals found in this area")
                            .font(.ui.largSemiBold)
                            .foregroundColor(.ui.white)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: defaultVPadding){
                                ForEach(hospitals) { item in
                                    HospitalRow(hospital: item, isSelected: selectedItem == nil ? nil : selectedItem!.id == item.id)
                                        .onTapGesture {
                                            onItemTapped(item)
                                        }
                                }
                            }
                            .padding(.horizontal, defaultHPadding)
                            .padding(.vertical, 20)
                            .padding(.bottom, offset)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, insets.bottom)
            .background(.ui.gray)
        }
        .background(.ui.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    @ViewBuilder
    private func segmentButton(type: HospitalListSegment,
                               selectedType: HospitalListSegment,
                               action: @escaping Action) -> some View {
        let selected = selectedType == type
        Button(action: action) {
            Text(type.title)
                .font(.ui.mRegular)
                .foregroundStyle(selected ? .ui.black : .ui.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? .ui.gray : .ui.white)
                .cornerRadius(16, corners: [.topLeft, .topRight])
        }
    }
}
