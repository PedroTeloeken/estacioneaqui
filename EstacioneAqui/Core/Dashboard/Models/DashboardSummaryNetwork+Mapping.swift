//
//  DashboardSummaryNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension DashboardSummaryNetwork {

    func toDomain() -> DashboardSummary {
        .init(
            balance: balance,
            activeParking: activeParking?.toDomain(),
            remainingMinutes: remainingMinutes,
            primaryVehicle: primaryVehicle?.toDomain(),
            monthlySpent: monthlySpent,
            totalSessions: totalSessions
        )
    }
}
