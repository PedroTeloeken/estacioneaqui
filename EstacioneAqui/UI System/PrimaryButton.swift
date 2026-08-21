//
//  PrimaryButton.swift
//  EstacioneAqui
//  Created by Pedro Teloeken on 26/06/26.
//  Copyright © 2026 teloeken. All rights reserved.
//


import SwiftUI

struct PrimaryButton: View {
    var title: LocalizedStringKey
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void
    
    private var isInteractionDisabled: Bool {
        isLoading || isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .tint(.onPrimaryBlue)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(Color.primaryBlue.opacity(isInteractionDisabled ? 0.4 : 1))
        .foregroundStyle(Color.onPrimaryBlue)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(isInteractionDisabled)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}
