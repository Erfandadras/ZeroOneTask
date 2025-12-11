//
//  HospitalRow.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/11/25.
//

import SwiftUI
import BaseModule
import CoreLocation

struct HospitalRow: View {
    let hospital: HospitalUIItem
    var isSelected: Bool?
    
    var body: some View {
        let notSelected = isSelected == false
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 20){
                Text("H")
                    .font(Font.Poppins.semiBold(32))
                    .foregroundStyle(.ui.white)
                    .frame(width: 48)
                    .background(notSelected ? .gray : .red)
                    .clipShape(.circle)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(hospital.name)
                        .font(.ui.largeRegular)
                        .lineLimit(1)
                    
                    HStack {
                        VStack(spacing: 4) {
                            Text(hospital.distanceInKm)
                                .font(.ui.sSemiBold)
                            Text("KM")
                                .font(.ui.largSemiBold)
                        }
                        
                        VStack(spacing: 4) {
                            Text(hospital.waitingTimeStr)
                                .font(.ui.smSemiBold)
                            Text("Waiting Time")
                                .font(.ui.sRegular)
                        }
                    }
                }
                .foregroundStyle(notSelected ? .black.opacity(0.4) : .red)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected == nil
                    ? .white
                    : isSelected! ? .white : .white.opacity(0.15))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
