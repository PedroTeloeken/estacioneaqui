//
//  ActiveSessionView.swift
//  EstacioneAqui
//


import SwiftUI

struct ActiveSessionView: View {
    var pendingAction: ParkingDeepLink?

    @Environment(ActiveSessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var isConfirmingFinish = false
    @State private var isConfirmingExtend = false

    private let extensionMinutes = 30

    var body: some View {
        NavigationStack {
            Group {
                if let session = sessionStore.session {
                    content(for: session)
                } else {
                    EmptyStateView(
                        icon: "checkmark.circle.fill",
                        title: "no_active_parking",
                        message: "session_ended"
                    )
                }
            }
            .navigationTitle("parking")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task(id: ActionTrigger(action: pendingAction, sessionId: sessionStore.session?.id)) {
            guard sessionStore.session != nil else { return }
            switch pendingAction {
            case .extend: isConfirmingExtend = true
            case .finish: isConfirmingFinish = true
            case .open, nil: break
            }
        }
    }

    private func content(for session: ParkingSession) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if let error = sessionStore.error {
                    ErrorBanner(error: error)
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(sessionStore.isOverdue ? .red : .green)
                        .frame(width: 9, height: 9)

                    Text(sessionStore.isOverdue ? "status_time_exceeded" : "status_parking_active")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(sessionStore.isOverdue ? .red : .green)
                }
                .padding(.top, 8)

                ring

                if sessionStore.isOverdue {
                    overdueWarning
                }

                detailsCard(for: session)

                actions
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [
                    sessionStore.isOverdue ? Color.red.opacity(0.14) : Color.secondaryBlue,
                    Color(.systemGroupedBackground),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut, value: sessionStore.isOverdue)
        )
    }

    private var ring: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let isOverdue = sessionStore.isOverdue
            let remaining = max(0, sessionStore.anchorEnd.timeIntervalSince(context.date))
            let elapsed = sessionStore.overdueElapsed(at: context.date)

            ZStack {
                CountdownRing(
                    progress: isOverdue ? 0 : sessionStore.progress(at: context.date),
                    lineWidth: 16,
                    tint: isOverdue ? .red : tint(forRemaining: remaining)
                )

                VStack(spacing: 4) {
                    Text(isOverdue ? "overtime_label" : "time_remaining_label")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isOverdue ? .red : .secondary)

                    Text((isOverdue ? "+" : "") + Self.timeString(isOverdue ? elapsed : remaining))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(isOverdue ? .red : .primary)
                        .contentTransition(.numericText(countsDown: !isOverdue))

                    Text(isOverdue
                         ? "ended_at \(sessionStore.anchorEnd.formatted(date: .omitted, time: .shortened))"
                         : "ends_at \(sessionStore.anchorEnd.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 250, height: 250)
        }
        .accessibilityElement(children: .combine)
    }

    private var overdueWarning: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text("subject_to_fine")
                    .font(.subheadline.weight(.semibold))

                Text("overdue_warning_body")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.red.opacity(0.12), in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func detailsCard(for session: ParkingSession) -> some View {
        VStack(spacing: 15) {
            HStack(spacing: 13) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primaryBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.primaryBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.areaName)
                        .font(.headline)

                    Text("blue_zone")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.primaryBlue)
                }

                Spacer()

                Text(DurationChips.label(forMinutes: session.minutesPurchased))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.primaryBlue.opacity(0.1), in: .capsule)
            }

            Divider()

            HStack {
                SessionFact(title: "plate", value: session.vehiclePlate, alignment: .leading)
                SessionFact(
                    title: "start_label",
                    value: session.startTime.formatted(date: .omitted, time: .shortened),
                    alignment: .center
                )
                SessionFact(
                    title: "end_label",
                    value: session.expectedEndTime.formatted(date: .omitted, time: .shortened),
                    alignment: .trailing
                )
            }

            Divider()

            valueSummary(for: session)
        }
        .padding(18)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    private func valueSummary(for session: ParkingSession) -> some View {
        let hourlyRate = session.hourlyRate

        return VStack(spacing: 10) {
            Text("summary")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            SummaryRow(
                title: "purchased_time",
                value: DurationChips.label(forMinutes: session.minutesPurchased)
            )

            if let hourlyRate {
                SummaryRow(title: "price_per_hour", value: hourlyRate.brl)
            }

            if sessionStore.isOverdue {
                SummaryRow(
                    title: "overtime",
                    value: String(localized: "overtime_minutes \(session.overdueMinutes)"),
                    tint: .red
                )
            }

            Divider()

            SummaryRow(title: "total_paid", value: session.amountPaid.brl, isEmphasized: true)

            if let cost = session.cost(forExtraMinutes: extensionMinutes) {
                Label(
                    "extend_estimate \(extensionMinutes) \(cost.brl)",
                    systemImage: "clock.badge.plus"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(spacing: 11) {
            if sessionStore.isOverdue {
                releaseButton
                extendButton
            } else {
                extendButton
                releaseButton
            }
        }
        .confirmationDialog(
            sessionStore.isOverdue
                ? "confirm_left_spot"
                : "end_parking_now",
            isPresented: $isConfirmingFinish,
            titleVisibility: .visible
        ) {
            Button(sessionStore.isOverdue ? "confirm_exit" : "end", role: .destructive) {
                Task {
                    await sessionStore.finish()
                    if sessionStore.session == nil {
                        dismiss()
                    }
                }
            }
        } message: {
            if sessionStore.isOverdue {
                Text("release_spot_message")
            }
        }
        .confirmationDialog(
            "extend_parking_now",
            isPresented: $isConfirmingExtend,
            titleVisibility: .visible
        ) {
            Button("extend_minutes \(extensionMinutes)") {
                Task { await sessionStore.extend(minutes: extensionMinutes) }
            }
        } message: {
            if let cost = sessionStore.session?.cost(forExtraMinutes: extensionMinutes) {
                Text("extend_estimate \(extensionMinutes) \(cost.brl)")
            }
        }
    }

    private var extendButton: some View {
        Button {
            Task { await sessionStore.extend(minutes: extensionMinutes) }
        } label: {
            Label("extend_minutes \(extensionMinutes)", systemImage: "clock.badge.plus")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .buttonStyle(.bordered)
        .tint(.primaryBlue)
        .disabled(sessionStore.isMutating)
    }

    @ViewBuilder
    private var releaseButton: some View {
        if sessionStore.isOverdue {
            Button {
                isConfirmingFinish = true
            } label: {
                Label("i_already_left", systemImage: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(sessionStore.isMutating)
        } else {
            Button(role: .destructive) {
                isConfirmingFinish = true
            } label: {
                Text("end_parking")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.bordered)
            .disabled(sessionStore.isMutating)
        }
    }

    private func tint(forRemaining remaining: TimeInterval) -> Color {
        if remaining < 5 * 60 { return .red }
        if remaining < 10 * 60 { return .orange }
        return .primaryBlue
    }

    static func timeString(_ interval: TimeInterval) -> String {
        let seconds = Int(interval.rounded())
        let pattern: Duration.TimeFormatStyle.Pattern = seconds >= 3600
            ? .hourMinuteSecond
            : .minuteSecond(padMinuteToLength: 2)
        return Duration.seconds(seconds).formatted(.time(pattern: pattern))
    }
}

private struct ActionTrigger: Equatable {
    let action: ParkingDeepLink?
    let sessionId: String?
}

private struct SessionFact: View {
    let title: LocalizedStringKey
    let value: String
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .accessibilityElement(children: .combine)
    }

    private var frameAlignment: Alignment {
        switch alignment {
        case .leading:  return .leading
        case .trailing: return .trailing
        default:        return .center
        }
    }
}

private struct SummaryRow: View {
    let title: LocalizedStringKey
    let value: String
    var isEmphasized = false
    var tint: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .font(isEmphasized ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundStyle(isEmphasized ? .primary : .secondary)

            Spacer(minLength: 12)

            Text(value)
                .font(isEmphasized ? .headline : .subheadline.weight(.medium))
                .foregroundStyle(tint)
        }
    }
}

private extension ParkingSession {
    var hourlyRate: Decimal? {
        guard minutesPurchased > 0 else { return nil }
        return (amountPaid / (Decimal(minutesPurchased) / 60)).roundedToCents
    }

    func cost(forExtraMinutes minutes: Int) -> Decimal? {
        guard let hourlyRate else { return nil }
        return (hourlyRate * (Decimal(minutes) / 60)).roundedToCents
    }
}

private extension Decimal {
    var roundedToCents: Decimal {
        var input = self
        var result = Decimal.zero
        NSDecimalRound(&result, &input, 2, .plain)
        return result
    }
}

#Preview {
    ActiveSessionView()
        .environment(ActiveSessionStore())
}
