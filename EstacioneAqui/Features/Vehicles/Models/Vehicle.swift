//
//  Vehicle.swift
//  EstacioneAqui
//


import Foundation

struct Vehicle: Identifiable, Equatable {
    let id: String
    let userId: String
    let plate: String
    let model: String?
    let color: String?
    let primaryVehicle: Bool
    let createdAt: Date?
    let updatedAt: Date?
}
