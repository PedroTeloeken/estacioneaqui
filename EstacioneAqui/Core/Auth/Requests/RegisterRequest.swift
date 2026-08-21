//
//  RegisterRequest.swift
//  EstacioneAqui
//


import Foundation

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
}
