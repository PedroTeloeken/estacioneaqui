//
//  EmptyStateView.swift
//  EstacioneAqui
//


import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: LocalizedStringKey
    var message: LocalizedStringKey?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            if let message {
                Text(message)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "car.fill",
        title: "no_vehicles",
        message: "no_vehicles_message"
    )
}
