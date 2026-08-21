//
//  AppNotification.swift
//  EstacioneAqui
//


import Foundation

struct AppNotification: Identifiable, Equatable {
    let id: String
    let userId: String
    let title: String
    let message: String
    var read: Bool
    let createdAt: Date
}
