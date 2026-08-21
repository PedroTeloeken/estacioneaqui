//
//  ParkingSessionNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension ParkingSessionNetwork {

    func toDomain() -> ParkingSession {
        .init(
            id: sessionId,
            userId: userId,
            vehicleId: vehicleId,
            vehiclePlate: vehiclePlate,
            areaId: areaId,
            areaName: areaName,
            latitude: latitude,
            longitude: longitude,
            startTime: startTime,
            expectedEndTime: expectedEndTime,
            endTime: endTime,
            minutesPurchased: minutesPurchased,
            amountPaid: amountPaid,
            remainingMinutes: remainingMinutes,
            overdueMinutes: overdueMinutes ?? 0,
            status: status.toDomain()
        )
    }
}

extension ParkingStatusNetwork {

    func toDomain() -> ParkingStatus {
        switch self {
        case .active:   return .active
        case .finished: return .finished
        case .overdue:  return .overdue
        }
    }
}

extension ParkingStatus {

    func toNetwork() -> ParkingStatusNetwork {
        switch self {
        case .active:   return .active
        case .finished: return .finished
        case .overdue:  return .overdue
        }
    }
}
