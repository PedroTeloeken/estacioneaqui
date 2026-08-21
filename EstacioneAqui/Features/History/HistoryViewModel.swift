//
//  HistoryViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {

    enum Period: String, CaseIterable, Identifiable {
        case last7Days
        case last30Days
        case all

        var id: String { rawValue }

        var label: LocalizedStringResource {
            switch self {
            case .last7Days:  return "period_last_7_days"
            case .last30Days: return "period_last_30_days"
            case .all:        return "period_all"
            }
        }

        var startDate: Date? {
            switch self {
            case .last7Days:  return Calendar.current.date(byAdding: .day, value: -7, to: .now)
            case .last30Days: return Calendar.current.date(byAdding: .day, value: -30, to: .now)
            case .all:        return nil
            }
        }
    }

    private(set) var sessions: [ParkingSession] = []
    private(set) var isLoading = false
    private(set) var isLoadingPage = false
    private(set) var reachedEnd = false
    var error: NetworkError?

    var statusFilter: ParkingStatus?
    var plateFilter = ""
    var period: Period = .all

    @ObservationIgnored private let service: ParkingServicing
    @ObservationIgnored private var page = 0
    private let pageSize = 20

    init(service: ParkingServicing = ParkingService()) {
        self.service = service
    }

    private var normalizedPlate: String? {
        let plate = plateFilter.trimmingCharacters(in: .whitespaces).uppercased()
        return plate.isEmpty ? nil : plate
    }

    func refresh() async {
        isLoading = sessions.isEmpty
        defer { isLoading = false }

        switch await service.history(
            startDate: period.startDate,
            endDate: nil,
            plate: normalizedPlate,
            status: statusFilter?.toNetwork(),
            page: 0,
            size: pageSize
        ) {
        case .success(let pageResponse):
            sessions = pageResponse.content.map { $0.toDomain() }
            page = 0
            reachedEnd = pageResponse.last
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func loadMoreIfNeeded(current session: ParkingSession) async {
        guard !reachedEnd, !isLoadingPage, !isLoading, session.id == sessions.last?.id else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }

        switch await service.history(
            startDate: period.startDate,
            endDate: nil,
            plate: normalizedPlate,
            status: statusFilter?.toNetwork(),
            page: page + 1,
            size: pageSize
        ) {
        case .success(let pageResponse):
            sessions += pageResponse.content.map { $0.toDomain() }
            page += 1
            reachedEnd = pageResponse.last
        case .error(let failure):
            error = failure
        }
    }
}
