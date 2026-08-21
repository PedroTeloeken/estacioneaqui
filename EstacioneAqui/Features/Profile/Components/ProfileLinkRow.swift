//
//  ProfileLinkRow.swift
//  EstacioneAqui
//


import SwiftUI

struct ProfileLinkRow: View {
    let icon: String
    let title: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 36, height: 36)
                .background(Color.primaryBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileLinkRow(icon: "car.fill", title: "my_vehicles")
        .padding()
}
