//
//  CreateVehicleRequest.swift
//  EstacioneAqui
//


import Foundation

struct CreateVehicleRequest: Encodable {
    let plate: String
    let model: String?
    let color: String?
    let primaryVehicle: Bool
}
