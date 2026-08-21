//
//  AuthViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {

    enum SessionState: Equatable {
        case loading
        case signedOut
        case signedIn(UserProfile)
    }

    private(set) var state: SessionState = .loading
    private(set) var isAuthenticating = false
    var error: NetworkError?

    @ObservationIgnored private let service: AuthServicing
    @ObservationIgnored private let tokenStore: TokenStore
    @ObservationIgnored private var sessionExpiryTask: Task<Void, Never>?

    init(service: AuthServicing = AuthService(), tokenStore: TokenStore = .shared) {
        self.service = service
        self.tokenStore = tokenStore

        sessionExpiryTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .sessionDidExpire) {
                guard let self, case .signedIn = self.state else { continue }
                self.state = .signedOut
            }
        }
    }

    deinit {
        sessionExpiryTask?.cancel()
    }

    func bootstrap() async {
        guard tokenStore.hasSession else {
            state = .signedOut
            return
        }
        switch await service.me() {
        case .success(let profile):
            state = .signedIn(profile.toDomain())
        case .error(let failure):
            switch failure {
            case .noConnection, .timeout, .serverUnavailable:
                state = .signedOut
            default:
                tokenStore.clear()
                state = .signedOut
            }
        }
    }

    func login(email: String, password: String) async {
        await authenticate {
            await self.service.login(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        }
    }

    func register(name: String, email: String, password: String) async {
        await authenticate {
            await self.service.register(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        }
    }

    func signOut() {
        tokenStore.clear()
        state = .signedOut
    }


    private func authenticate(_ operation: @escaping () async -> NetworkResult<LoginResponseNetwork>) async {
        guard !isAuthenticating else { return }
        error = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        switch await operation() {
        case .success(let response):
            tokenStore.save(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            state = .signedIn(response.user.toDomain())
        case .error(let failure):
            error = failure
        }
    }
}
