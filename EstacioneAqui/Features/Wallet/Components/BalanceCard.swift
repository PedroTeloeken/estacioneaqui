//
//  BalanceCard.swift
//  EstacioneAqui
//


import SwiftUI

struct BalanceCard: View {
    let balance: Decimal?
    let isLoading: Bool
    let onTopUp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("available_balance")
                    .font(.subheadline)
                    .foregroundStyle(Color.onPrimaryBlue.opacity(0.8))

                Group {
                    if isLoading && balance == nil {
                        ProgressView()
                            .tint(Color.onPrimaryBlue)
                    } else {
                        Text((balance ?? 0).brl)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.onPrimaryBlue)
                            .contentTransition(.numericText())
                    }
                }
            }

            Button(action: onTopUp) {
                Label("add_balance", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.onPrimaryBlue.opacity(0.18))
                    .foregroundStyle(Color.onPrimaryBlue)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .animation(.default, value: balance)
    }
}

#Preview {
    BalanceCard(balance: 42.5, isLoading: false, onTopUp: {})
        .padding()
}
