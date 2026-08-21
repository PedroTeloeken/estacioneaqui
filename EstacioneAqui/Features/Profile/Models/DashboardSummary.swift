//
//  DashboardSummary.swift
//  EstacioneAqui
//


import Foundation

struct DashboardSummary: Equatable {
    let balance: Decimal
    let activeParking: ParkingSession?
    let remainingMinutes: Int64?
    let primaryVehicle: Vehicle?
    let monthlySpent: Decimal
    let totalSessions: Int64
}
