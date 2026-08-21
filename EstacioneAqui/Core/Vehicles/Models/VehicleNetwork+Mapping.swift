//
//  VehicleNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension VehicleNetwork {

    func toDomain() -> Vehicle {
        .init(
            id: id,
            userId: userId,
            plate: plate,
            model: model,
            color: color,
            primaryVehicle: primaryVehicle,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
