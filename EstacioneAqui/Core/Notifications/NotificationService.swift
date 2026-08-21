//
//  NotificationService.swift
//  EstacioneAqui
//


import Foundation

protocol NotificationServicing {
    func list(page: Int, size: Int) async -> NetworkResult<PageResponse<AppNotificationNetwork>>
    func markRead(id: String) async -> NetworkResult<EmptyResponse>
    func markAllRead() async -> NetworkResult<EmptyResponse>
}

struct NotificationService: NotificationServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func list(page: Int, size: Int) async -> NetworkResult<PageResponse<AppNotificationNetwork>> {
        await client.request(
            .get,
            "/api/v1/notifications",
            query: ["page": String(page), "size": String(size)],
            authenticated: true
        )
    }

    func markRead(id: String) async -> NetworkResult<EmptyResponse> {
        await client.request(.patch, "/api/v1/notifications/\(id)/read", authenticated: true)
    }

    func markAllRead() async -> NetworkResult<EmptyResponse> {
        await client.request(.patch, "/api/v1/notifications/read-all", authenticated: true)
    }
}
