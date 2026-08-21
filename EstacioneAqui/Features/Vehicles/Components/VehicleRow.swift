//
//  VehicleRow.swift
//  EstacioneAqui
//


import SwiftUI

struct VehicleRow: View {
    let vehicle: Vehicle

    private var subtitle: String {
        [vehicle.model, vehicle.color]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 40, height: 40)
                .background(Color.primaryBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.plate)
                    .font(.headline)
                    .monospaced()

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if vehicle.primaryVehicle {
                Text("primary")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primaryBlue.opacity(0.12))
                    .foregroundStyle(Color.primaryBlue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VehicleRow(
        vehicle: Vehicle(
            id: "1",
            userId: "u1",
            plate: "BRA2E19",
            model: "Honda Civic",
            color: "Preto",
            primaryVehicle: true,
            createdAt: nil,
            updatedAt: nil
        )
    )
    .padding()
}
