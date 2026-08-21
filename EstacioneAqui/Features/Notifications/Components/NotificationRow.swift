//
//  NotificationRow.swift
//  EstacioneAqui
//


import SwiftUI

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(notification.read ? Color.clear : Color.primaryBlue)
                .frame(width: 9, height: 9)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(.subheadline.weight(notification.read ? .medium : .bold))

                Text(notification.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(notification.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            (notification.read ? "" : String(localized: "unread_prefix")) + "\(notification.title). \(notification.message)"
        )
    }
}

#Preview {
    List {
        NotificationRow(
            notification: AppNotification(
                id: "1",
                userId: "u",
                title: "Estacionamento expirando",
                message: "Sua sessão no Centro termina em 10 minutos.",
                read: false,
                createdAt: .now
            )
        )
    }
}
