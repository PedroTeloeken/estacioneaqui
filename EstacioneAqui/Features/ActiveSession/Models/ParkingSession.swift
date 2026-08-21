//
//  ParkingSession.swift
//  EstacioneAqui
//


import Foundation

struct ParkingSession: Identifiable, Equatable {
    let id: String
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
    let overdueMinutes: Int64
    let status: ParkingStatus
}
