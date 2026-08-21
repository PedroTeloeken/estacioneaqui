//
//  WalletService.swift
//  EstacioneAqui
//


import Foundation

protocol WalletServicing {
    func wallet() async -> NetworkResult<WalletNetwork>
    func topUp(amount: Decimal, description: String?) async -> NetworkResult<WalletNetwork>
    func transactions(page: Int, size: Int) async -> NetworkResult<PageResponse<WalletTransactionNetwork>>
}

struct WalletService: WalletServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func wallet() async -> NetworkResult<WalletNetwork> {
        await client.request(.get, "/api/v1/wallet", authenticated: true)
    }

    func topUp(amount: Decimal, description: String?) async -> NetworkResult<WalletNetwork> {
        await client.request(
            .post,
            "/api/v1/wallet/topup",
            body: TopUpRequest(amount: amount, description: description),
            authenticated: true
        )
    }

    func transactions(page: Int, size: Int) async -> NetworkResult<PageResponse<WalletTransactionNetwork>> {
        await client.request(
            .get,
            "/api/v1/wallet/transactions",
            query: ["page": String(page), "size": String(size)],
            authenticated: true
        )
    }
}
