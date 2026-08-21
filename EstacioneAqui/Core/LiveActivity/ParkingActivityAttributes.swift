//
//  ParkingActivityAttributes.swift
//  EstacioneAqui
//


import ActivityKit
import Foundation

struct ParkingActivityAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable {
        var anchorEnd: Date
        var totalDuration: TimeInterval
        var isOverdue: Bool

        var paidWindow: ClosedRange<Date> {
            anchorEnd.addingTimeInterval(-max(60, totalDuration))...anchorEnd
        }

        var overdueWindow: ClosedRange<Date> {
            anchorEnd...anchorEnd.addingTimeInterval(12 * 3600)
        }
    }

    let sessionId: String
    let plate: String
    let areaName: String
}
