//
//  LocationService.swift
//  EstacioneAqui
//


import CoreLocation
import Observation

@MainActor
@Observable
final class LocationService {

    private(set) var lastLocation: CLLocation?
    private(set) var isAuthorizationDenied = false

    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    @ObservationIgnored private var liveUpdatesTask: Task<Void, Never>?

    func start() {
        guard updatesTask == nil else { return }

        #if DEBUG
        updatesTask = Task { [weak self] in
            for await override in DebugLocationOverride.shared.changes() {
                guard let self, !Task.isCancelled else { return }

                self.liveUpdatesTask?.cancel()
                self.liveUpdatesTask = nil

                if let override {
                    self.isAuthorizationDenied = false
                    self.lastLocation = CLLocation(
                        latitude: override.latitude,
                        longitude: override.longitude
                    )
                } else {
                    self.startLiveUpdates()
                }
            }
        }
        #else
        startLiveUpdates()
        updatesTask = liveUpdatesTask
        #endif
    }

    func stop() {
        liveUpdatesTask?.cancel()
        liveUpdatesTask = nil
        updatesTask?.cancel()
        updatesTask = nil
    }

    private func startLiveUpdates() {
        liveUpdatesTask = Task { [weak self] in
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    guard let self, !Task.isCancelled else { return }
                    if let location = update.location {
                        self.lastLocation = location
                    }
                    self.isAuthorizationDenied = update.authorizationDenied
                }
            } catch {
                self?.isAuthorizationDenied = true
            }
        }
    }
}
