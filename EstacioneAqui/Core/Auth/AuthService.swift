//
//  AuthService.swift
//  EstacioneAqui
//


import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async -> NetworkResult<LoginResponseNetwork>
    func register(name: String, email: String, password: String) async -> NetworkResult<LoginResponseNetwork>
    func refresh(refreshToken: String) async -> NetworkResult<RefreshResponseNetwork>
    func me() async -> NetworkResult<UserProfileNetwork>
}

struct AuthService: AuthServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func login(email: String, password: String) async -> NetworkResult<LoginResponseNetwork> {
        Self.remapAuthErrors(await client.request(
            .post,
            "/api/v1/auth/login",
            body: LoginRequest(email: email, password: password)
        ))
    }

    func register(name: String, email: String, password: String) async -> NetworkResult<LoginResponseNetwork> {
        Self.remapAuthErrors(await client.request(
            .post,
            "/api/v1/auth/register",
            body: RegisterRequest(name: name, email: email, password: password)
        ))
    }

    func refresh(refreshToken: String) async -> NetworkResult<RefreshResponseNetwork> {
        await client.request(
            .post,
            "/api/v1/auth/refresh",
            body: RefreshRequest(refreshToken: refreshToken)
        )
    }

    func me() async -> NetworkResult<UserProfileNetwork> {
        await client.request(.get, "/api/v1/auth/me", authenticated: true)
    }

    private static func remapAuthErrors(_ result: NetworkResult<LoginResponseNetwork>) -> NetworkResult<LoginResponseNetwork> {
        guard case let .error(error) = result else { return result }
        switch error {
        case .badRequest, .sessionExpired, .forbidden:
            return .error(.invalidCredentials)
        case .conflict:
            return .error(.emailAlreadyInUse)
        default:
            return result
        }
    }
}
