//
//  WalletTransactionNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension WalletTransactionNetwork {

    func toDomain() -> WalletTransaction {
        .init(
            id: id,
            walletId: walletId,
            type: type.toDomain(),
            amount: amount,
            description: description,
            createdAt: createdAt
        )
    }
}

extension TransactionTypeNetwork {

    func toDomain() -> TransactionType {
        switch self {
        case .credit: return .credit
        case .debit:  return .debit
        }
    }
}
