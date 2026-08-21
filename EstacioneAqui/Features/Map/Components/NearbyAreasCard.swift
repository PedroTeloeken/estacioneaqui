//
//  NearbyAreasCard.swift
//  EstacioneAqui
//


import SwiftUI

struct NearbyAreasCard: View {
    let areas: [ParkingArea]
    let discoveredAreaId: String?
    let onSelect: (ParkingArea) -> Void

    @State private var isExpanded = true
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            handle

            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    GlassEffectContainer(spacing: 10) {
                        HStack(spacing: 10) {
                            ForEach(areas) { area in
                                AreaMiniCard(
                                    area: area,
                                    isHere: area.id == discoveredAreaId,
                                    onTap: { onSelect(area) }
                                )
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 20, for: .scrollContent)
                .transition(.opacity)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 18)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .shadow(color: .elevationShadow, radius: 16, y: 6)
        .offset(y: dragOffset)
        .animation(.snappy(duration: 0.3), value: isExpanded)
    }

    private var handle: some View {
        VStack(alignment: .leading, spacing: 12) {
            Capsule()
                .fill(.tertiary)
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)

            HStack(alignment: .firstTextBaseline) {
                Text("active_areas")
                    .font(.title3.weight(.semibold))

                Spacer()

                Text("\(areas.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 20)
        }
        .contentShape(.rect)
        .onTapGesture { isExpanded.toggle() }
        .gesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    let raw = value.translation.height
                    dragOffset = isExpanded ? max(0, min(raw, 60)) : max(-60, min(raw, 0))
                }
                .onEnded { value in
                    let travel = value.translation.height
                    if isExpanded, travel > 30 {
                        isExpanded = false
                    } else if !isExpanded, travel < -30 {
                        isExpanded = true
                    }
                    withAnimation(.snappy(duration: 0.25)) { dragOffset = 0 }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("active_areas_count \(areas.count)")
        .accessibilityHint(isExpanded ? "tap_to_collapse" : "tap_to_expand")
        .accessibilityAddTraits(.isButton)
    }
}

private struct AreaMiniCard: View {
    let area: ParkingArea
    let isHere: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "parkingsign")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.onPrimaryBlue)
                        .frame(width: 26, height: 26)
                        .background(Color.primaryBlue, in: .circle)

                    Spacer(minLength: 0)

                    if isHere {
                        Text("youre_here")
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.18), in: .capsule)
                            .foregroundStyle(.green)
                            .fixedSize()
                    }
                }

                Text(area.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.top, 12)

                Text(area.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 2)

                Spacer(minLength: 12)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(area.pricePerHour.brl)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.primaryBlue)

                    Text("/h")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .frame(width: 186, height: 148, alignment: .leading)
            .contentShape(.rect(cornerRadius: 22))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isHere
                ? "area_accessibility_here \(area.name) \(area.city) \(area.pricePerHour.brl)"
                : "area_accessibility \(area.name) \(area.city) \(area.pricePerHour.brl)"
        )
    }
}

#Preview {
    NearbyAreasCard(
        areas: [
            ParkingArea(id: "1", name: "Centro", city: "Blumenau", pricePerHour: 3, maxMinutes: 120, active: true, zone: nil, createdAt: nil, updatedAt: nil),
            ParkingArea(id: "2", name: "Garcia", city: "Blumenau", pricePerHour: 2, maxMinutes: 180, active: true, zone: nil, createdAt: nil, updatedAt: nil),
            ParkingArea(id: "3", name: "Velha Central", city: "Blumenau", pricePerHour: 2.5, maxMinutes: 180, active: true, zone: nil, createdAt: nil, updatedAt: nil),
        ],
        discoveredAreaId: "2",
        onSelect: { _ in }
    )
    .padding()
}
