//
//  WalletNetwork.swift
//  EstacioneAqui
//


import Foundation

struct WalletNetwork: Decodable {
    let id: String
    let userId: String
    let balance: Decimal
}
