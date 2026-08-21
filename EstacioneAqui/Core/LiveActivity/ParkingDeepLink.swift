//
//  ParkingDeepLink.swift
//  EstacioneAqui
//


import Foundation

enum ParkingDeepLink: String {
    case open = "open"
    case extend = "extend"
    case finish = "finish"

    static let scheme = "estacioneaqui"
    private static let host = "session"

    var url: URL {
        URL(string: "\(Self.scheme)://\(Self.host)/\(rawValue)")!
    }

    init?(url: URL) {
        guard url.scheme == Self.scheme, url.host() == Self.host else { return nil }
        let action = url.pathComponents.last(where: { $0 != "/" }) ?? Self.open.rawValue
        self.init(rawValue: action)
    }
}
