//
//  LoginResponseNetwork.swift
//  EstacioneAqui
//


import Foundation

struct LoginResponseNetwork: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserProfileNetwork
}
