//
//  ProfileViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    private(set) var summary: DashboardSummary?
    private(set) var isLoading = false
    var error: NetworkError?

    @ObservationIgnored private let service: DashboardServicing

    init(service: DashboardServicing = DashboardService()) {
        self.service = service
    }

    func load() async {
        isLoading = summary == nil
        defer { isLoading = false }

        switch await service.dashboard() {
        case .success(let summary):
            self.summary = summary.toDomain()
            error = nil
        case .error(let failure):
            error = failure
        }
    }
}
