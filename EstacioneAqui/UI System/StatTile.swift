//
//  StatTile.swift
//  EstacioneAqui
//


import SwiftUI

struct StatTile: View {
    let icon: String
    let title: LocalizedStringKey
    let value: String
    var tint: Color = .primaryBlue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(tint)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(spacing: 12) {
        StatTile(icon: "wallet.bifold.fill", title: "balance", value: "R$ 42,50")
        StatTile(icon: "calendar", title: "spent_this_month", value: "R$ 18,00")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
