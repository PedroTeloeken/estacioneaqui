//
//  UserProfileNetwork+Mapping.swift
//  EstacioneAqui
//


import Foundation

extension UserProfileNetwork {

    func toDomain() -> UserProfile {
        .init(
            id: id,
            name: name,
            email: email,
            profilePicture: profilePicture,
            createdAt: createdAt
        )
    }
    
}
