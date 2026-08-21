//
//  TokenRefreshCoordinator.swift
//  EstacioneAqui
//


import Foundation

enum RefreshOutcome {
    case refreshed
    case invalid
    case transient(NetworkError)
}

actor TokenRefreshCoordinator {

    static let shared = TokenRefreshCoordinator()

    private var inFlight: Task<RefreshOutcome, Never>?

    func refresh() async -> RefreshOutcome {
        if let inFlight {
            return await inFlight.value
        }

        let task = Task<RefreshOutcome, Never> {
            let store = TokenStore.shared
            guard let refreshToken = store.refreshToken else { return .invalid }

            switch await AuthService().refresh(refreshToken: refreshToken) {
            case .success(let response):
                store.updateAccessToken(response.accessToken, refreshToken: response.refreshToken)
                return .refreshed
            case .error(let error):
                switch error {
                case .badRequest, .sessionExpired, .forbidden, .invalidCredentials, .conflict:
                    return .invalid
                default:
                    return .transient(error)
                }
            }
        }

        inFlight = task
        let outcome = await task.value
        inFlight = nil
        return outcome
    }
}
