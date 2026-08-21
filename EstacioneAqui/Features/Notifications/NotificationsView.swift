//
//  NotificationsView.swift
//  EstacioneAqui
//


import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.notifications.isEmpty {
                EmptyStateView(
                    icon: "bell",
                    title: "no_notifications",
                    message: "no_notifications_message"
                )
            } else {
                notificationsList
            }
        }
        .navigationTitle("notifications")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("mark_all_read") {
                    Task { await viewModel.markAllRead() }
                }
                .disabled(viewModel.unreadCount == 0)
            }
        }
        .task {
            await viewModel.refresh()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var notificationsList: some View {
        List {
            if let error = viewModel.error {
                ErrorBanner(error: error)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.notifications) { notification in
                NotificationRow(notification: notification)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { await viewModel.markRead(notification) }
                    }
                    .task {
                        await viewModel.loadMoreIfNeeded(current: notification)
                    }
            }

            if viewModel.isLoadingPage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.notifications)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
