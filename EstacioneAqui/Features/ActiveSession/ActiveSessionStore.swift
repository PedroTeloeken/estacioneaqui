//
//  ActiveSessionStore.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class ActiveSessionStore {

    private(set) var session: ParkingSession?
    private(set) var anchorEnd: Date = .distantPast
    private(set) var isMutating = false
    var error: NetworkError?

    @ObservationIgnored private let service: ParkingServicing
    @ObservationIgnored private let liveActivity: LiveActivityController

    init(
        service: ParkingServicing = ParkingService(),
        liveActivity: LiveActivityController? = nil
    ) {
        self.service = service
        self.liveActivity = liveActivity ?? .shared
    }

    var totalDuration: TimeInterval {
        TimeInterval((session?.minutesPurchased ?? 0) * 60)
    }

    var isOverdue: Bool {
        session?.status == .overdue
    }

    func overdueElapsed(at date: Date) -> TimeInterval {
        max(0, date.timeIntervalSince(anchorEnd))
    }

    func progress(at date: Date) -> Double {
        guard totalDuration > 0 else { return 0 }
        let remaining = anchorEnd.timeIntervalSince(date)
        return min(1, max(0, remaining / totalDuration))
    }

    func refresh() async {
        switch await service.active() {
        case .success(let session):
            apply(session?.toDomain())
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func adopt(_ session: ParkingSession) {
        apply(session)
    }

    func extend(minutes: Int = 30) async {
        guard let session, !isMutating else { return }
        isMutating = true
        defer { isMutating = false }

        switch await service.extend(id: session.id, additionalMinutes: minutes) {
        case .success(let updated):
            apply(updated.toDomain())
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func finish() async {
        guard let session, !isMutating else { return }
        isMutating = true
        defer { isMutating = false }

        switch await service.finish(id: session.id) {
        case .success:
            apply(nil)
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    private func apply(_ session: ParkingSession?) {
        guard let session, session.status.isInProgress else {
            self.session = nil
            anchorEnd = .distantPast
            liveActivity.sync(session: nil, anchorEnd: anchorEnd)
            return
        }

        self.session = session
        anchorEnd = session.status == .overdue
            ? Date.now.addingTimeInterval(-TimeInterval(session.overdueMinutes) * 60)
            : Date.now.addingTimeInterval(TimeInterval(session.remainingMinutes) * 60)

        liveActivity.sync(session: session, anchorEnd: anchorEnd)
    }
}
