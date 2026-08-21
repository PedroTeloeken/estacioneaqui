//
//  ParkingStatusNetwork.swift
//  EstacioneAqui
//


import Foundation

enum ParkingStatusNetwork: String, Decodable {
    case active = "ACTIVE"
    case finished = "FINISHED"
    case overdue = "OVERDUE"
}
