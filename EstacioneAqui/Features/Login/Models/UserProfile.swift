//
//  UserProfile.swift
//  EstacioneAqui
//


import Foundation

struct UserProfile: Identifiable, Equatable {
    let id: String
    let name: String
    let email: String
    let profilePicture: String?
    let createdAt: Date?
}
