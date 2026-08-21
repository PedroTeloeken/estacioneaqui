//
//  ErrorBanner.swift
//  EstacioneAqui
//


import SwiftUI

struct ErrorBanner: View {
    let error: NetworkError

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: error.icon)
                .font(.system(size: 16, weight: .medium))

            Text(error.message)
                .font(.subheadline)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .foregroundStyle(.red)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ErrorBanner(error: .invalidCredentials)
        .padding()
}
