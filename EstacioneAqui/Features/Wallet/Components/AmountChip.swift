//
//  AmountChip.swift
//  EstacioneAqui
//


import SwiftUI

struct AmountChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(isSelected ? Color.onPrimaryBlue : Color.primary)
                .glassEffect(
                    isSelected ? .regular.tint(.primaryBlue) : .regular,
                    in: .capsule
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    HStack {
        AmountChip(label: "R$ 10,00", isSelected: false, action: {})
        AmountChip(label: "R$ 25,00", isSelected: true, action: {})
    }
    .padding()
}
