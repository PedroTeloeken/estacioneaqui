//
//  ActiveSessionMiniBar.swift
//  EstacioneAqui
//


import SwiftUI

struct ActiveSessionMiniBar: View {
    let session: ParkingSession
    let anchorEnd: Date

    @Environment(\.tabViewBottomAccessoryPlacement) private var placement

    private var isOverdue: Bool { session.status == .overdue }
    private var accent: Color { isOverdue ? .red : .green }

    private var isInline: Bool { placement == .inline }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let remaining = max(0, anchorEnd.timeIntervalSince(context.date))

            HStack(spacing: 12) {
                badge(remaining: remaining)

                if isInline {
                    timer(remaining: remaining)
                    Spacer(minLength: 8)
                } else {
                    VStack(alignment: .leading, spacing: 1) {
                        header
                        timer(remaining: remaining)
                    }
                    Spacer(minLength: 8)
                }

                Text(session.vehiclePlate)
                    .font(.subheadline.weight(.semibold))
                    .monospaced()
                    .foregroundStyle(.secondary)
                    .layoutPriority(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isOverdue
                ? "minibar_accessibility_overdue \(session.areaName) \(session.vehiclePlate)"
                : "minibar_accessibility_active \(session.areaName) \(session.vehiclePlate)"
        )
        .accessibilityHint(isOverdue ? "minibar_hint_overdue" : "minibar_hint_active")
    }

    @ViewBuilder
    private func badge(remaining: TimeInterval) -> some View {
        let total = TimeInterval(session.minutesPurchased * 60)
        let size: CGFloat = isInline ? 24 : 32

        ZStack {
            if total > 0 {
                CountdownRing(
                    progress: isOverdue ? 0 : min(1, max(0, remaining / total)),
                    lineWidth: 3,
                    tint: isOverdue ? .red : tint(forRemaining: remaining)
                )
            }

            Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "parkingsign")
                .font(.system(size: isInline ? 11 : 14, weight: .semibold))
                .foregroundStyle(isOverdue ? .red : Color.primaryBlue)
        }
        .frame(width: size, height: size)
    }

    private var header: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)

            Text(isOverdue ? "status_exceeded_short" : "status_active_short")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(accent)
                .fixedSize()

            Text("·")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.tertiary)

            Text(session.areaName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private func timer(remaining: TimeInterval) -> some View {
        Text(
            timerInterval: isOverdue ? anchorEnd...Date.now : Date.now...max(anchorEnd, .now),
            countsDown: !isOverdue
        )
        .font(.headline.monospacedDigit())
        .foregroundStyle(tint(forRemaining: remaining))
        .lineLimit(1)
    }

    private func tint(forRemaining remaining: TimeInterval) -> Color {
        if isOverdue { return .red }
        if remaining < 5 * 60 { return .red }
        if remaining < 10 * 60 { return .orange }
        return .primary
    }
}
