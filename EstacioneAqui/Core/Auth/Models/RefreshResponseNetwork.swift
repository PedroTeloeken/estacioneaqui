//
//  RefreshResponseNetwork.swift
//  EstacioneAqui
//


import Foundation

struct RefreshResponseNetwork: Decodable {
    let accessToken: String
    let refreshToken: String
}
