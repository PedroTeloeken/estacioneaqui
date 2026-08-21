//
//  CustomTextField.swift
//  EstacioneAqui
//  Created by Pedro Teloeken on 26/06/26.
//  Copyright © 2026 teloeken. All rights reserved.
//


import SwiftUI

struct CustomTextField: View {
    var icon: String
    var placeholder: LocalizedStringKey
    @Binding var text: String
    var isValid: Bool
    var isUserSubmitted: Bool
    var errorMessage: LocalizedStringKey
    var autocapitalization: TextInputAutocapitalization = .never

    private var showError: Bool {
        isUserSubmitted && (!isValid || text.isEmpty)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(text.isEmpty ? .secondary : .primaryBlue)
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(autocapitalization)
                    .disableAutocorrection(true)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .glassEffect(.regular, in: .rect(cornerRadius: 14))
            .background(Color.fieldSurface, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(showError ? Color.red : Color.clear, lineWidth: 1.5)
            )
            
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showError)
    }
}
