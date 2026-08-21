//
//  ParkingAreaNetwork+Mapping.swift
//  EstacioneAqui
//


import CoreLocation
import Foundation

extension ParkingAreaNetwork {

    func toDomain() -> ParkingArea {
        .init(
            id: id,
            name: name,
            city: city,
            pricePerHour: pricePerHour,
            maxMinutes: maxMinutes,
            active: active,
            zone: zone,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private var zone: ParkingArea.Zone? {
        guard let centerLatitude, let centerLongitude, let radiusMeters, radiusMeters > 0 else {
            return nil
        }
        return .init(
            center: .init(latitude: centerLatitude, longitude: centerLongitude),
            radius: radiusMeters
        )
    }
}
