//
//  AppNotificationNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension AppNotificationNetwork {

    func toDomain() -> AppNotification {
        .init(
            id: id,
            userId: userId,
            title: title,
            message: message,
            read: read,
            createdAt: createdAt
        )
    }
}
