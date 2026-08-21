//
//  CarRouteCard.swift
//  EstacioneAqui
//


import CoreLocation
import MapKit
import SwiftUI

struct CarRouteCard: View {
    let session: ParkingSession
    let straightLineDistance: CLLocationDistance?
    let route: MKRoute?
    let isCalculating: Bool
    let error: String?
    let onRoute: () -> Void
    let onOpenInMaps: () -> Void
    let onClearRoute: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            facts

            if let error {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            actions
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .shadow(color: .elevationShadow, radius: 16, y: 6)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("my_car")
                    .font(.title3.bold())

                Text(session.areaName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primaryBlue)
                    .lineLimit(1)
            }

            Spacer()

            Text(session.vehiclePlate)
                .font(.subheadline.weight(.semibold))
                .monospaced()
                .foregroundStyle(.secondary)

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
    }

    @ViewBuilder
    private var facts: some View {
        if let route {
            HStack(spacing: 10) {
                RouteFactTile(title: "distance", value: Self.distanceLabel(route.distance))
                RouteFactTile(title: "on_foot", value: Self.timeLabel(route.expectedTravelTime))
            }
        } else if let straightLineDistance {
            RouteFactTile(
                title: "straight_line",
                value: Self.distanceLabel(straightLineDistance)
            )
        }
    }

    @ViewBuilder
    private var actions: some View {
        if route != nil {
            PrimaryButton(title: "open_in_maps", action: onOpenInMaps)

            Button("clear_route", action: onClearRoute)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        } else if straightLineDistance != nil {
            PrimaryButton(title: "get_walking_directions", isLoading: isCalculating, action: onRoute)

            Button("open_in_maps", action: onOpenInMaps)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        } else {
            PrimaryButton(title: "open_in_maps", action: onOpenInMaps)
        }
    }

    static func distanceLabel(_ meters: CLLocationDistance) -> String {
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let display = meters >= 1000 ? measurement.converted(to: .kilometers) : measurement
        return display.formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(meters >= 1000 ? 1 : 0))
            )
        )
    }

    static func timeLabel(_ seconds: TimeInterval) -> String {
        Duration.seconds(max(60, seconds))
            .formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}

private struct RouteFactTile: View {
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
