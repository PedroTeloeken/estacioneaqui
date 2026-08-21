//
//  UpdateVehicleRequest.swift
//  EstacioneAqui
//


import Foundation

struct UpdateVehicleRequest: Encodable {
    let plate: String
    let model: String?
    let color: String?
    let primaryVehicle: Bool
}
