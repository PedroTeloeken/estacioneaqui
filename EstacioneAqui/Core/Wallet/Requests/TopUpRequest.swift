//
//  TopUpRequest.swift
//  EstacioneAqui
//


import Foundation

struct TopUpRequest: Encodable {
    let amount: Decimal
    let description: String?
}
