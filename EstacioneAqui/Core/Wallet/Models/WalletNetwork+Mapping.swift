//
//  WalletNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension WalletNetwork {

    func toDomain() -> Wallet {
        .init(
            id: id,
            userId: userId,
            balance: balance
        )
    }
}
