//
//  VehiclePickerCard.swift
//  EstacioneAqui
//


import SwiftUI

struct VehiclePickerCard: View {
    let vehicle: Vehicle
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(isSelected ? AnyShapeStyle(Color.primaryBlue) : AnyShapeStyle(.tertiary))
                        .frame(width: 9, height: 9)

                    Text(vehicle.plate)
                        .font(.headline)
                        .monospaced()
                }

                Text(vehicle.model ?? String(localized: "vehicle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(minWidth: 140, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AnyShapeStyle(Color.primaryBlue) : AnyShapeStyle(.quaternary), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    HStack {
        VehiclePickerCard(
            vehicle: Vehicle(id: "1", userId: "u", plate: "BRA2E19", model: "Honda Civic", color: nil, primaryVehicle: true, createdAt: nil, updatedAt: nil),
            isSelected: true,
            onTap: {}
        )
        VehiclePickerCard(
            vehicle: Vehicle(id: "2", userId: "u", plate: "QXK7H88", model: "Fiat Argo", color: nil, primaryVehicle: false, createdAt: nil, updatedAt: nil),
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
}
