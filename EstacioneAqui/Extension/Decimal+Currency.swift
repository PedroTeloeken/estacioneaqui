//
//  Decimal+Currency.swift
//  EstacioneAqui
//


import Foundation

extension Decimal {
    var brl: String {
        formatted(.currency(code: "BRL").locale(Locale(identifier: "pt_BR")))
    }
}
