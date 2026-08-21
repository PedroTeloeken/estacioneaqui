//
//  SessionHistoryRow.swift
//  EstacioneAqui
//


import SwiftUI

struct SessionHistoryRow: View {
    let session: ParkingSession

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "parkingsign")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 40, height: 40)
                .background(Color.primaryBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.areaName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text("\(session.vehiclePlate) · \(session.startTime.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(session.amountPaid.brl)
                    .font(.subheadline.weight(.semibold))

                StatusBadge(status: session.status)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct StatusBadge: View {
    let status: ParkingStatus

    private var color: Color {
        switch status {
        case .active:   return .green
        case .finished: return .secondary
        case .overdue:  return .red
        }
    }

    var body: some View {
        Text(status.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.13))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    SessionHistoryRow(
        session: ParkingSession(
            id: "1",
            userId: "u",
            vehicleId: "v",
            vehiclePlate: "BRA2E19",
            areaId: "a",
            areaName: "Centro",
            latitude: 0,
            longitude: 0,
            startTime: .now,
            expectedEndTime: .now.addingTimeInterval(3600),
            endTime: nil,
            minutesPurchased: 60,
            amountPaid: 3,
            remainingMinutes: 30,
            overdueMinutes: 0,
            status: .finished
        )
    )
    .padding()
}
