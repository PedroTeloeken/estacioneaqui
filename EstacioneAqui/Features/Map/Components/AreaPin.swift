//
//  AreaPin.swift
//  EstacioneAqui
//


import SwiftUI

struct AreaPin: View {
    let priceLabel: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "parkingsign")
                    .font(.system(size: 12, weight: .bold))

                Text(priceLabel)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(isSelected ? Color.primaryBlue : Color(.systemBackground))
            .foregroundStyle(isSelected ? Color.onPrimaryBlue : Color.primaryBlue)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.primaryBlue.opacity(isSelected ? 1 : 0.25), lineWidth: 1.5)
            )
            .shadow(color: .elevationShadow, radius: 7, y: 4)

            PinTail()
                .fill(isSelected ? Color.primaryBlue : Color(.systemBackground))
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityLabel("blue_area_price \(priceLabel)")
    }
}

struct PinTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        AreaPin(priceLabel: "R$ 3,00", isSelected: false)
        AreaPin(priceLabel: "R$ 3,00", isSelected: true)
    }
    .padding()
}
