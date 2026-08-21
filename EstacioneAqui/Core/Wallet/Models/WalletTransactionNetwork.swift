//
//  WalletTransactionNetwork.swift
//  EstacioneAqui
//


import Foundation

struct WalletTransactionNetwork: Decodable {
    let id: String
    let walletId: String
    let type: TransactionTypeNetwork
    let amount: Decimal
    let description: String?
    let createdAt: Date
}
