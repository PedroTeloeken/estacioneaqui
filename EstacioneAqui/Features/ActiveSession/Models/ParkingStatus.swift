//
//  ParkingStatus.swift
//  EstacioneAqui
//


import Foundation

enum ParkingStatus: CaseIterable, Equatable {
    case active
    case finished
    case overdue

    var label: String {
        switch self {
        case .active:   return String(localized: "status_active")
        case .finished: return String(localized: "status_finished")
        case .overdue:  return String(localized: "status_overdue")
        }
    }

    var isInProgress: Bool {
        self == .active || self == .overdue
    }
}
