//
//  LiveActivityController.swift
//  EstacioneAqui
//


import ActivityKit
import Foundation

@MainActor
final class LiveActivityController {

    static let shared = LiveActivityController()

    private let overdueVisibility: TimeInterval = 2 * 3600

    private init() {}

    func sync(session: ParkingSession?, anchorEnd: Date) {
        guard let session else {
            end(activities)
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let state = ParkingActivityAttributes.ContentState(
            anchorEnd: anchorEnd,
            totalDuration: TimeInterval(session.minutesPurchased * 60),
            isOverdue: session.status == .overdue
        )
        let content = ActivityContent(state: state, staleDate: staleDate(for: state))

        let (current, obsolete) = activities.partitioned { $0.attributes.sessionId == session.id }
        end(obsolete)

        if let activity = current.first {
            Task { await activity.update(content) }
        } else {
            start(session: session, content: content)
        }
    }

    private var activities: [Activity<ParkingActivityAttributes>] {
        Activity<ParkingActivityAttributes>.activities
    }

    private func start(
        session: ParkingSession,
        content: ActivityContent<ParkingActivityAttributes.ContentState>
    ) {
        let attributes = ParkingActivityAttributes(
            sessionId: session.id,
            plate: session.vehiclePlate,
            areaName: session.areaName
        )
        _ = try? Activity.request(attributes: attributes, content: content)
    }

    private func end(_ activities: [Activity<ParkingActivityAttributes>]) {
        for activity in activities {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }
    }

    private func staleDate(for state: ParkingActivityAttributes.ContentState) -> Date {
        state.isOverdue
            ? state.anchorEnd.addingTimeInterval(overdueVisibility)
            : state.anchorEnd
    }
}

private extension Array {
    func partitioned(by belongsToFirst: (Element) -> Bool) -> ([Element], [Element]) {
        reduce(into: ([Element](), [Element]())) { result, element in
            belongsToFirst(element) ? result.0.append(element) : result.1.append(element)
        }
    }
}
