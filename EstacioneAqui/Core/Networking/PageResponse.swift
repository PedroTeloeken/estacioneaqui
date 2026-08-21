//
//  PageResponse.swift
//  EstacioneAqui
//


import Foundation

struct PageResponse<T: Decodable>: Decodable {
    let content: [T]
    let page: Int
    let size: Int
    let totalElements: Int64
    let totalPages: Int
    let last: Bool
}
