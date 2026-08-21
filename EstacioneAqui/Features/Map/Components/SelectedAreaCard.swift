//
//  SelectedAreaCard.swift
//  EstacioneAqui
//


import SwiftUI

struct SelectedAreaCard: View {
    enum Availability {
        case available
        case outsideArea
        case sessionInProgress
    }

    let area: ParkingArea
    let availability: Availability
    let isZoneVisible: Bool
    let onClose: () -> Void
    let onPark: () -> Void
    let onToggleZone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(area.name)
                        .font(.title3.bold())

                    Text("blue_zone_city \(area.city)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.primaryBlue)
                }

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                        .background(.quaternary, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("close")
            }

            HStack(spacing: 10) {
                AreaFactTile(title: "per_hour", value: area.pricePerHour.brl)
                AreaFactTile(title: "max_time", value: DurationChips.label(forMinutes: area.maxMinutes))
            }

            if area.zone != nil {
                Button(action: onToggleZone) {
                    Label(
                        isZoneVisible ? "hide_zone" : "show_zone",
                        systemImage: isZoneVisible ? "eye.slash" : "circle.dashed"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(.rect(cornerRadius: 14))
                    .background(Color.primaryBlue.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }

            switch availability {
            case .available:
                PrimaryButton(title: "park_here", action: onPark)

            case .outsideArea:
                unavailableNote("must_be_in_area",
                                icon: "location.slash")

            case .sessionInProgress:
                unavailableNote("session_in_progress_note",
                                icon: "parkingsign.circle")
            }
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .shadow(color: .elevationShadow, radius: 16, y: 6)
    }

    private func unavailableNote(_ text: LocalizedStringKey, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AreaFactTile: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SelectedAreaCard(
        area: ParkingArea(
            id: "1",
            name: "Centro",
            city: "Blumenau",
            pricePerHour: 3,
            maxMinutes: 120,
            active: true,
            zone: .init(center: .init(latitude: -26.9175, longitude: -49.0720), radius: 487),
            createdAt: nil,
            updatedAt: nil
        ),
        availability: .available,
        isZoneVisible: false,
        onClose: {},
        onPark: {},
        onToggleZone: {}
    )
    .padding()
}
