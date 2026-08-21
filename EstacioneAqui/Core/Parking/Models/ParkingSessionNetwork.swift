//
//  ParkingSessionNetwork.swift
//  EstacioneAqui
//


import Foundation

struct ParkingSessionNetwork: Decodable {
    let sessionId: String
    let userId: String
    let vehicleId: String
    let vehiclePlate: String
    let areaId: String
    let areaName: String
    let latitude: Double
    let longitude: Double
    let startTime: Date
    let expectedEndTime: Date
    let endTime: Date?
    let minutesPurchased: Int
    let amountPaid: Decimal
    let remainingMinutes: Int64
    let overdueMinutes: Int64?
    let status: ParkingStatusNetwork
}
