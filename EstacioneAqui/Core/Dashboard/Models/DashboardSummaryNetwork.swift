//
//  DashboardSummaryNetwork.swift
//  EstacioneAqui
//


import Foundation

struct DashboardSummaryNetwork: Decodable {
    let balance: Decimal
    let activeParking: ParkingSessionNetwork?
    let remainingMinutes: Int64?
    let primaryVehicle: VehicleNetwork?
    let monthlySpent: Decimal
    let totalSessions: Int64
}
