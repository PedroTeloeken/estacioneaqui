//
//  ParkingArea.swift
//  EstacioneAqui
//


import CoreLocation
import Foundation

struct ParkingArea: Identifiable, Equatable {
    struct Zone: Equatable {
        let center: CLLocationCoordinate2D
        let radius: CLLocationDistance

        static func == (lhs: Zone, rhs: Zone) -> Bool {
            lhs.center.latitude == rhs.center.latitude
                && lhs.center.longitude == rhs.center.longitude
                && lhs.radius == rhs.radius
        }
    }

    let id: String
    let name: String
    let city: String
    let pricePerHour: Decimal
    let maxMinutes: Int
    let active: Bool
    let zone: Zone?
    let createdAt: Date?
    let updatedAt: Date?
}
