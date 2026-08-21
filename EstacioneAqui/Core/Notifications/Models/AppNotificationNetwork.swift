//
//  AppNotificationNetwork.swift
//  EstacioneAqui
//


import Foundation

struct AppNotificationNetwork: Decodable {
    let id: String
    let userId: String
    let title: String
    let message: String
    let read: Bool
    let createdAt: Date
}
