//
//  WalletViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class WalletViewModel {

    private(set) var wallet: Wallet?
    private(set) var transactions: [WalletTransaction] = []
    private(set) var isLoading = false
    private(set) var isLoadingPage = false
    private(set) var isToppingUp = false
    private(set) var reachedEnd = false
    var error: NetworkError?

    @ObservationIgnored private let service: WalletServicing
    @ObservationIgnored private var page = 0
    private let pageSize = 20

    init(service: WalletServicing = WalletService()) {
        self.service = service
    }

    func load() async {
        isLoading = wallet == nil
        defer { isLoading = false }

        async let walletResult = service.wallet()
        async let pageResult = service.transactions(page: 0, size: pageSize)

        switch await walletResult {
        case .success(let wallet):
            self.wallet = wallet.toDomain()
            error = nil
        case .error(let failure):
            error = failure
        }

        switch await pageResult {
        case .success(let pageResponse):
            transactions = pageResponse.content.map { $0.toDomain() }
            page = 0
            reachedEnd = pageResponse.last
        case .error(let failure):
            error = failure
        }
    }

    func loadMoreIfNeeded(current transaction: WalletTransaction) async {
        guard !reachedEnd, !isLoadingPage, !isLoading, transaction.id == transactions.last?.id else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }

        switch await service.transactions(page: page + 1, size: pageSize) {
        case .success(let pageResponse):
            transactions += pageResponse.content.map { $0.toDomain() }
            page += 1
            reachedEnd = pageResponse.last
        case .error(let failure):
            error = failure
        }
    }

    func topUp(amount: Decimal, description: String?) async -> Bool {
        guard !isToppingUp else { return false }
        error = nil
        isToppingUp = true
        defer { isToppingUp = false }

        switch await service.topUp(amount: amount, description: description) {
        case .success:
            await load()
            return true
        case .error(let failure):
            error = failure
            return false
        }
    }
}
