//
//  VehicleNetwork.swift
//  EstacioneAqui
//


import Foundation

struct VehicleNetwork: Decodable {
    let id: String
    let userId: String
    let plate: String
    let model: String?
    let color: String?
    let primaryVehicle: Bool
    let createdAt: Date?
    let updatedAt: Date?
}
