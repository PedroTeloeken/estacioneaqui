//
//  UserProfileNetwork.swift
//  EstacioneAqui
//


import Foundation

struct UserProfileNetwork: Decodable {
    let id: String
    let name: String
    let email: String
    let profilePicture: String?
    let createdAt: Date?
}
