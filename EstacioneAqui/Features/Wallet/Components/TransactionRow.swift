//
//  TransactionRow.swift
//  EstacioneAqui
//


import SwiftUI

struct TransactionRow: View {
    let transaction: WalletTransaction

    private var isCredit: Bool { transaction.type == .credit }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isCredit ? "arrow.down.left" : "arrow.up.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isCredit ? .green : .red)
                .frame(width: 36, height: 36)
                .background((isCredit ? Color.green : Color.red).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description ?? String(localized: isCredit ? "credit" : "debit"))
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(transaction.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text((isCredit ? "+" : "−") + transaction.amount.brl)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isCredit ? .green : .primary)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    TransactionRow(
        transaction: WalletTransaction(
            id: "1",
            walletId: "w1",
            type: .credit,
            amount: 50,
            description: "Crédito teste",
            createdAt: .now
        )
    )
}
