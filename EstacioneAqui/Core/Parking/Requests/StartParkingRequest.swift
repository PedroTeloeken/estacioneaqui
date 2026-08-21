//
//  StartParkingRequest.swift
//  EstacioneAqui
//


import Foundation

struct StartParkingRequest: Encodable {
    let vehicleId: String
    let latitude: Double
    let longitude: Double
    let minutes: Int
}
