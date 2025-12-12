//
//  GetDirectionModalView.swift
//  ZeroOneErfanTask
//
//  Created by Erfan mac mini on 12/12/25.
//

import SwiftUI
import BaseModule

enum TransportType: Identifiable, CaseIterable {
    var id: Int {
        self.hashValue
    }
    case car
    case publicTransportation
}

struct GetDirectionModalView: View {
    // MARK: - properties
    @Environment(\.safeAreaInsets) private var insets
    @Environment(\.dismiss) private var dismiss
    @State private var maxHeight: CGFloat = 50
    let callback: (TransportType) -> Void
    
    // MARK: - view
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottom){
                VStack {
                    Button {
                        callback(.car)
                        dismiss()
                    } label: {
                        Text("Get Direction With Car")
                            .font(.ui.mRegular)
                            .foregroundStyle(.ui.white)
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16,
                                          backgroundColor: .ui.red)
                    }
                    .padding(.top, 20)
                    
                    Button {
                        callback(.car)
                        dismiss()
                    } label: {
                        Text("Get Direction With Public Transportation")
                            .font(.ui.mRegular)
                            .foregroundStyle(.ui.red)
                            .frame(height: 36)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16,
                                          backgroundColor: .ui.white)
                            .addBorder(with: 16, color: .ui.red, width: 1)
                        
                    }
                    .padding(.top, 20)
                }// VStack
                .padding(.horizontal, 12.updateForHeight())
                .padding(.bottom, insets.bottom)
                .padding(.top, 32.updateForHeight())
            }//Zstack
            .sizeChangePrefenece { size in
                maxHeight = size.height
            }
        }
        .background(.ui.white)
        .cornerRadius(20.updateForHeight(), corners: [.topLeft, .topRight])
        .background(BackgroundClearView())
        .ignoresSafeArea(.all)
        .presentationDetents(maxHeight <= 50 ? [.height(50)] : [.height(maxHeight - insets.bottom)])
    }
}
