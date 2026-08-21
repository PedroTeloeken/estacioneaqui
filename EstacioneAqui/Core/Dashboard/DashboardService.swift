//
//  DashboardService.swift
//  EstacioneAqui
//


import Foundation

protocol DashboardServicing {
    func dashboard() async -> NetworkResult<DashboardSummaryNetwork>
}

struct DashboardService: DashboardServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func dashboard() async -> NetworkResult<DashboardSummaryNetwork> {
        await client.request(.get, "/api/v1/dashboard", authenticated: true)
    }
}
