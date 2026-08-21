//
//  NetworkError.swift
//  EstacioneAqui
//


import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyInUse
    case badRequest
    case sessionExpired
    case conflict
    case forbidden
    case notFound
    case serverUnavailable
    case noConnection
    case timeout
    case invalidResponse
    case decodingFailed
    case unknown

    var message: String {
        switch self {
        case .invalidCredentials: return String(localized: "error_invalid_credentials")
        case .emailAlreadyInUse:  return String(localized: "error_email_in_use")
        case .badRequest:         return String(localized: "error_bad_request")
        case .sessionExpired:     return String(localized: "error_session_expired")
        case .conflict:           return String(localized: "error_conflict")
        case .forbidden:          return String(localized: "error_forbidden")
        case .notFound:           return String(localized: "error_not_found")
        case .serverUnavailable:  return String(localized: "error_server_unavailable")
        case .noConnection:       return String(localized: "error_no_connection")
        case .timeout:            return String(localized: "error_timeout")
        case .invalidResponse:    return String(localized: "error_invalid_response")
        case .decodingFailed:     return String(localized: "error_decoding_failed")
        case .unknown:            return String(localized: "error_unknown")
        }
    }

    var icon: String {
        switch self {
        case .invalidCredentials: return "lock.trianglebadge.exclamationmark"
        case .emailAlreadyInUse:  return "person.crop.circle.badge.exclamationmark"
        case .badRequest:         return "exclamationmark.circle.fill"
        case .sessionExpired:     return "lock.rotation"
        case .conflict:           return "doc.on.doc.fill"
        case .forbidden:          return "hand.raised.fill"
        case .notFound:           return "magnifyingglass"
        case .serverUnavailable:  return "exclamationmark.icloud.fill"
        case .noConnection:       return "wifi.slash"
        case .timeout:            return "clock.badge.exclamationmark"
        case .invalidResponse,
             .decodingFailed,
             .unknown:            return "exclamationmark.triangle.fill"
        }
    }

    var errorDescription: String? { message }

    static func from(status: Int) -> NetworkError {
        switch status {
        case 400, 422: return .badRequest
        case 401:      return .sessionExpired
        case 403:      return .forbidden
        case 404:      return .notFound
        case 409:      return .conflict
        case 500...599: return .serverUnavailable
        default:       return .unknown
        }
    }
}
