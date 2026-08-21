//
//  DurationChips.swift
//  EstacioneAqui
//


import SwiftUI

struct DurationChips: View {
    let options: [Int]
    @Binding var selection: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { minutes in
                    let isSelected = minutes == selection

                    Button {
                        selection = minutes
                    } label: {
                        Text(Self.label(forMinutes: minutes))
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .foregroundStyle(isSelected ? Color.onPrimaryBlue : Color.primary)
                            .glassEffect(
                                isSelected ? .regular.tint(.primaryBlue) : .regular,
                                in: .capsule
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: selection)
    }

    static func label(forMinutes minutes: Int) -> String {
        let hours = minutes / 60
        let rest = minutes % 60
        if hours == 0 { return "\(minutes) min" }
        if rest == 0 { return "\(hours)h" }
        return "\(hours)h\(rest)"
    }
}

#Preview {
    DurationChips(options: [30, 60, 90, 120], selection: .constant(60))
        .padding()
}
