//
//  WalletTransaction.swift
//  EstacioneAqui
//


import Foundation

struct WalletTransaction: Identifiable, Equatable, Hashable {
    let id: String
    let walletId: String
    let type: TransactionType
    let amount: Decimal
    let description: String?
    let createdAt: Date
}
