//
//  NetworkResult.swift
//  EstacioneAqui
//


import Foundation

enum NetworkResult<Success> {
    case success(Success)
    case error(NetworkError)
}
