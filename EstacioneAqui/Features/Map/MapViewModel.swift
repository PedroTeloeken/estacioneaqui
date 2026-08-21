//
//  MapViewModel.swift
//  EstacioneAqui
//


import Foundation
import CoreLocation
import Observation

@MainActor
@Observable
final class MapViewModel {

    private(set) var areas: [ParkingArea] = []
    private(set) var discoveredArea: ParkingArea?
    private(set) var isDiscovering = false
    var selectedArea: ParkingArea? {
        didSet {
            if selectedArea?.id != oldValue?.id { visibleZoneAreaId = nil }
        }
    }
    private(set) var visibleZoneAreaId: String?
    var error: NetworkError?

    @ObservationIgnored private let service: AreaServicing
    @ObservationIgnored private var lastDiscoveryLocation: CLLocation?

    private let rediscoveryDistance: CLLocationDistance = 100

    init(service: AreaServicing = AreaService()) {
        self.service = service
    }

    @discardableResult
    func toggleVisibleZone() -> ParkingArea.Zone? {
        guard let selectedArea, let zone = selectedArea.zone else { return nil }

        if visibleZoneAreaId == selectedArea.id {
            visibleZoneAreaId = nil
            return nil
        }
        visibleZoneAreaId = selectedArea.id
        return zone
    }

    func loadAreas() async {
        switch await service.areas() {
        case .success(let areas):
            self.areas = areas.filter(\.active).map { $0.toDomain() }
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func discoverIfNeeded(at location: CLLocation) async {
        if let last = lastDiscoveryLocation, location.distance(from: last) < rediscoveryDistance {
            return
        }
        guard !isDiscovering else { return }
        isDiscovering = true
        defer { isDiscovering = false }
        lastDiscoveryLocation = location

        switch await service.discover(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        ) {
        case .success(let area):
            if let selectedArea, selectedArea.id == discoveredArea?.id, selectedArea.id != area?.id {
                self.selectedArea = area?.toDomain()
            }
            discoveredArea = area?.toDomain()
        case .error:
            lastDiscoveryLocation = nil
        }
    }
}
