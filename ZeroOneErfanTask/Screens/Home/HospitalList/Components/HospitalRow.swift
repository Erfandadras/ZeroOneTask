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
        let notSelected = hospital.availability ? isSelected == false : true
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 20){
                Text("H")
                    .font(Font.Poppins.semiBold(32))
                    .foregroundStyle(.ui.white)
                    .frame(width: 48)
                    .background(notSelected ? .ui.gray : .ui.red)
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
                .foregroundStyle(notSelected ? .ui.black.opacity(0.4) : .ui.red)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected == nil
                    ? .ui.white
                    : isSelected! ? .ui.white : .ui.white.opacity(0.15))
        .cornerRadius(12)
        .shadow(color: .ui.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
