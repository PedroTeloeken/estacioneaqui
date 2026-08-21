//
//  NetworkClient.swift
//  EstacioneAqui
//


import Foundation
import Alamofire

extension Notification.Name {
    static let sessionDidExpire = Notification.Name("EstacioneAqui.sessionDidExpire")
}

struct EmptyResponse: Decodable {}

final class NetworkClient {

    static let shared = NetworkClient()

    private let session: Session
    private let decoder: JSONDecoder
    private let refreshCoordinator: TokenRefreshCoordinator

    init(session: Session = .estacioneAqui, refreshCoordinator: TokenRefreshCoordinator = .shared) {
        self.session = session
        self.refreshCoordinator = refreshCoordinator

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            guard let date = NetworkClient.parseDate(raw) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Formato de data não reconhecido: \(raw)"
                ))
            }
            return date
        }
        self.decoder = decoder
    }

    func request<Response: Decodable, Body: Encodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [String: String?]? = nil,
        body: Body?,
        authenticated: Bool = false
    ) async -> NetworkResult<Response> {
        var response = await perform(method, path, query: query, body: body, authenticated: authenticated)

        if authenticated, let status = response.response?.statusCode, status == 401 || status == 403 {
            switch await refreshCoordinator.refresh() {
            case .refreshed:
                response = await perform(method, path, query: query, body: body, authenticated: authenticated)
            case .invalid:
                TokenStore.shared.clear()
                NotificationCenter.default.post(name: .sessionDidExpire, object: nil)
                return .error(.sessionExpired)
            case .transient(let failure):
                return .error(failure)
            }
        }

        return decodeResult(response)
    }

    func request<Response: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [String: String?]? = nil,
        authenticated: Bool = false
    ) async -> NetworkResult<Response> {
        await request(
            method,
            path,
            query: query,
            body: Optional<EmptyBody>.none,
            authenticated: authenticated
        )
    }


    private func perform<Body: Encodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [String: String?]?,
        body: Body?,
        authenticated: Bool
    ) async -> AFDataResponse<Data> {
        var url = APIConfig.baseURL.appendingPathComponent(path)
        let queryItems = (query ?? [:]).compactMap { key, value in
            value.map { URLQueryItem(name: key, value: $0) }
        }
        if !queryItems.isEmpty {
            url.append(queryItems: queryItems)
        }

        var headers: HTTPHeaders = ["Accept": "application/json"]
        if authenticated, let token = TokenStore.shared.accessToken {
            headers.add(name: APIConfig.authHeaderName, value: token)
        }

        return await session.request(
            url,
            method: method,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
        .validate()
        .serializingData(emptyResponseCodes: [200, 204, 205])
        .response
    }


    private func decodeResult<Response: Decodable>(_ response: AFDataResponse<Data>) -> NetworkResult<Response> {
        switch response.result {
        case let .success(data):
            if data.isEmpty {
                if let empty = EmptyResponse() as? Response {
                    return .success(empty)
                }
                if let decoded = try? decoder.decode(Response.self, from: Data("null".utf8)) {
                    return .success(decoded)
                }
                return .error(.decodingFailed)
            }
            do {
                return .success(try decoder.decode(Response.self, from: data))
            } catch {
                return .error(.decodingFailed)
            }
        case let .failure(error):
            if let status = response.response?.statusCode {
                return .error(.from(status: status))
            }
            return .error(Self.mapTransport(error))
        }
    }

    static func parseDate(_ raw: String) -> Date? {
        if let date = isoFractionFormatter.date(from: raw) { return date }
        if let date = isoFormatter.date(from: raw) { return date }

        let parts = raw.split(separator: ".", maxSplits: 1)
        guard let base = parts.first, let date = localFormatter.date(from: String(base)) else {
            return nil
        }
        if parts.count == 2 {
            guard parts[1].allSatisfy(\.isNumber), let fraction = Double("0.\(parts[1])") else {
                return nil
            }
            return date.addingTimeInterval(fraction)
        }
        return date
    }

    private static let isoFractionFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let localFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()

    private static func mapTransport(_ error: Error) -> NetworkError {
        let urlError = (error.asAFError?.underlyingError as? URLError) ?? (error as? URLError)
        switch urlError?.code {
        case .some(.notConnectedToInternet), .some(.networkConnectionLost), .some(.dataNotAllowed):
            return .noConnection
        case .some(.timedOut):
            return .timeout
        default:
            return .unknown
        }
    }
}

private struct EmptyBody: Encodable {}
