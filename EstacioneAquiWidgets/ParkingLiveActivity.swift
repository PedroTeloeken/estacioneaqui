//
//  ParkingLiveActivity.swift
//  EstacioneAquiWidgets
//


import ActivityKit
import SwiftUI
import WidgetKit

struct ParkingLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ParkingActivityAttributes.self) { context in
            LockScreenView(context: context)
                .activityBackgroundTint(.black.opacity(0.45))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedIdentity(context: context, showsStatus: false)
                        .padding(.top, 6)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    SessionTimer(context: context, font: .title2.weight(.bold))
                        .frame(maxWidth: 128, alignment: .trailing)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        if context.isOverdue {
                            Label("la_subject_to_fine", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ProgressView(timerInterval: context.state.paidWindow)
                                .tint(.green)
                                .labelsHidden()
                        }

                        SessionActions(isOverdue: context.isOverdue)
                    }
                }
            } compactLeading: {
                if context.isOverdue {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: "car.fill")
                        .foregroundStyle(.green)
                }
            } compactTrailing: {
                CompactTime(context: context)
            } minimal: {
                Image(systemName: context.isOverdue ? "exclamationmark.triangle.fill" : "parkingsign")
                    .foregroundStyle(context.isOverdue ? .red : .green)
            }
            .widgetURL(ParkingDeepLink.open.url)
            .keylineTint(context.isOverdue ? .red : .green)
        }
    }
}


private struct LockScreenView: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        VStack(spacing: 14) {
            ExpandedIdentity(context: context)

            SessionTimer(context: context, font: .system(size: 40, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)

            if context.isOverdue {
                Label("la_subject_to_fine", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ProgressView(timerInterval: context.state.paidWindow)
                    .tint(.green)
                    .labelsHidden()
            }

            SessionActions(isOverdue: context.isOverdue)
        }
        .padding(16)
    }
}


private struct ExpandedIdentity: View {
    let context: ActivityViewContext<ParkingActivityAttributes>
    var showsStatus = true

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            if showsStatus {
                Text(context.isOverdue ? "la_overtime" : "la_time_remaining")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(context.isOverdue ? .red : .green)
            }

            Text(context.attributes.plate)
                .font(.subheadline.weight(.bold))

            Text(context.attributes.areaName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SessionTimer: View {
    let context: ActivityViewContext<ParkingActivityAttributes>
    let font: Font

    var body: some View {
        HStack(spacing: 0) {
            if context.isOverdue {
                Text(verbatim: "+")
                Text(timerInterval: context.state.overdueWindow, countsDown: false)
            } else {
                Text(timerInterval: context.state.paidWindow, countsDown: true)
            }
        }
        .font(font)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(context.isOverdue ? .red : .primary)
    }
}

private struct CompactTime: View {
    let context: ActivityViewContext<ParkingActivityAttributes>

    var body: some View {
        Group {
            if context.fitsCompactTicker {
                if context.isOverdue {
                    Text(timerInterval: context.state.overdueWindow, countsDown: false)
                } else {
                    Text(timerInterval: context.state.paidWindow, countsDown: true)
                }
            } else {
                Text(context.state.anchorEnd, style: .time)
            }
        }
        .font(.caption2.weight(.semibold))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .foregroundStyle(context.isOverdue ? .red : .primary)
        .frame(width: 50, alignment: .trailing)
    }
}

private struct SessionActions: View {
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: 8) {
            if isOverdue {
                action("la_finish", systemImage: "checkmark.circle.fill", link: .finish, isProminent: true)
                action("la_extend", systemImage: "clock.badge.plus", link: .extend, isProminent: false)
            } else {
                action("la_extend", systemImage: "clock.badge.plus", link: .extend, isProminent: true)
                action("la_finish", systemImage: "checkmark.circle.fill", link: .finish, isProminent: false)
            }
        }
    }

    private func action(
        _ title: LocalizedStringKey,
        systemImage: String,
        link: ParkingDeepLink,
        isProminent: Bool
    ) -> some View {
        Link(destination: link.url) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(
                    Capsule().fill(isProminent ? tint.opacity(0.85) : Color.white.opacity(0.14))
                )
                .foregroundStyle(isProminent ? Color.black : .white)
        }
    }

    private var tint: Color {
        isOverdue ? .red : .green
    }
}

private extension ActivityViewContext where Attributes == ParkingActivityAttributes {
    var isOverdue: Bool {
        state.isOverdue || isStale
    }

    var fitsCompactTicker: Bool {
        abs(state.anchorEnd.timeIntervalSinceNow) < 3600
    }
}
