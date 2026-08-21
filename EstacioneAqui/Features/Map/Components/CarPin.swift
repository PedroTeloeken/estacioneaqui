//
//  CarPin.swift
//  EstacioneAqui
//


import SwiftUI

struct CarPin: View {
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "car.fill")
                    .font(.system(size: 12, weight: .bold))

                Text("my_car")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(Color.primaryBlue)
            .foregroundStyle(Color.onPrimaryBlue)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.onPrimaryBlue.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
            )
            .shadow(color: .elevationShadow, radius: 7, y: 4)

            PinTail()
                .fill(Color.primaryBlue)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityLabel("your_parked_car")
        .accessibilityHint("car_pin_hint")
    }
}

#Preview {
    VStack(spacing: 20) {
        CarPin(isSelected: false)
        CarPin(isSelected: true)
    }
    .padding()
}
