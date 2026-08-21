//
//  ParkingAreaNetwork.swift
//  EstacioneAqui
//


import Foundation

struct ParkingAreaNetwork: Decodable {
    let id: String
    let name: String
    let city: String
    let pricePerHour: Decimal
    let maxMinutes: Int
    let active: Bool
    let centerLatitude: Double?
    let centerLongitude: Double?
    let radiusMeters: Double?
    let createdAt: Date?
    let updatedAt: Date?
}
