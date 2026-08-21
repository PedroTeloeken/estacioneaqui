//
//  NotificationsViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class NotificationsViewModel {

    private(set) var notifications: [AppNotification] = []
    private(set) var isLoading = false
    private(set) var isLoadingPage = false
    private(set) var reachedEnd = false
    var error: NetworkError?

    @ObservationIgnored private let service: NotificationServicing
    @ObservationIgnored private var page = 0
    private let pageSize = 20

    var unreadCount: Int {
        notifications.filter { !$0.read }.count
    }

    init(service: NotificationServicing = NotificationService()) {
        self.service = service
    }

    func refresh() async {
        isLoading = notifications.isEmpty
        defer { isLoading = false }

        switch await service.list(page: 0, size: pageSize) {
        case .success(let pageResponse):
            notifications = pageResponse.content.map { $0.toDomain() }
            page = 0
            reachedEnd = pageResponse.last
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func loadMoreIfNeeded(current notification: AppNotification) async {
        guard !reachedEnd, !isLoadingPage, notification.id == notifications.last?.id else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }

        switch await service.list(page: page + 1, size: pageSize) {
        case .success(let pageResponse):
            notifications += pageResponse.content.map { $0.toDomain() }
            page += 1
            reachedEnd = pageResponse.last
        case .error(let failure):
            error = failure
        }
    }

    func markRead(_ notification: AppNotification) async {
        guard !notification.read else { return }

        setRead(true, for: notification.id)
        if case .error(let failure) = await service.markRead(id: notification.id) {
            setRead(false, for: notification.id)
            error = failure
        }
    }

    func markAllRead() async {
        guard unreadCount > 0 else { return }

        switch await service.markAllRead() {
        case .success:
            notifications = notifications.map { notification in
                var updated = notification
                updated.read = true
                return updated
            }
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    private func setRead(_ read: Bool, for id: String) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].read = read
    }
}
