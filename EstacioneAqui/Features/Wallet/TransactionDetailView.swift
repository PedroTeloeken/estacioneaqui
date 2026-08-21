//
//  TransactionDetailView.swift
//  EstacioneAqui
//


import SwiftUI
import UIKit

struct TransactionDetailView: View {
    let transaction: WalletTransaction

    @State private var didCopyId = false

    private var isCredit: Bool { transaction.type == .credit }
    private var accent: Color { isCredit ? .green : .red }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                details
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("transaction")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: isCredit ? "arrow.down.left" : "arrow.up.right")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 64, height: 64)
                .background(accent.opacity(0.12), in: .circle)

            Text((isCredit ? "+" : "−") + transaction.amount.brl)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(isCredit ? accent : .primary)
                .contentTransition(.numericText())

            Text(transaction.type.label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var details: some View {
        VStack(spacing: 0) {
            DetailRow(
                label: "description_label",
                value: transaction.description ?? transaction.type.label
            )

            Divider().padding(.leading, 16)

            DetailRow(
                label: "date_label",
                value: transaction.createdAt.formatted(date: .long, time: .shortened)
            )

            Divider().padding(.leading, 16)

            Button {
                UIPasteboard.general.string = transaction.id
                withAnimation { didCopyId = true }
            } label: {
                DetailRow(
                    label: "identifier_label",
                    value: transaction.id,
                    isMonospaced: true,
                    trailingIcon: didCopyId ? "checkmark" : "doc.on.doc"
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct DetailRow: View {
    let label: LocalizedStringKey
    let value: String
    var isMonospaced = false
    var trailingIcon: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 16)

            Text(value)
                .font(isMonospaced ? .caption.monospaced() : .subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)

            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: WalletTransaction(
                id: "8f14e45f-ceea-467a-9c1e-3b2a7d9f0011",
                walletId: "w1",
                type: .debit,
                amount: 6,
                description: "Estacionamento — Centro",
                createdAt: .now
            )
        )
    }
}
