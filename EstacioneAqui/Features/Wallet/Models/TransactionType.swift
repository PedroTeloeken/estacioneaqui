//
//  TransactionType.swift
//  EstacioneAqui
//


import Foundation

enum TransactionType: Equatable, Hashable {
    case credit
    case debit

    var label: String {
        switch self {
        case .credit: String(localized: "credit")
        case .debit: String(localized: "debit")
        }
    }
}
