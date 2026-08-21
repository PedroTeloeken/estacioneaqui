//
//  DebugAreaLocator.swift
//  EstacioneAqui
//


#if DEBUG

import CoreLocation
import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class DebugAreaLocator {

    enum State: Equatable {
        case unknown
        case locating
        case located(CLLocationCoordinate2D)
        case notFound

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown), (.locating, .locating), (.notFound, .notFound):
                return true
            case (.located(let a), .located(let b)):
                return a.latitude == b.latitude && a.longitude == b.longitude
            default:
                return false
            }
        }
    }

    private(set) var states: [String: State] = [:]
    private(set) var isLocatingAll = false

    @ObservationIgnored private let service: AreaServicing
    private static let cacheKey = "debug.location.areaCoordinates"

    private let probeRadii: [CLLocationDistance] = [0, 300, 700]
    private let probeBearings = 6

    init(service: AreaServicing = AreaService()) {
        self.service = service
        let cached = UserDefaults.standard.dictionary(forKey: Self.cacheKey) as? [String: [Double]]
        for (areaId, pair) in cached ?? [:] where pair.count == 2 {
            states[areaId] = .located(.init(latitude: pair[0], longitude: pair[1]))
        }
    }

    func coordinate(for areaId: String) -> CLLocationCoordinate2D? {
        if case .located(let coordinate) = states[areaId] { return coordinate }
        return nil
    }

    func remember(_ coordinate: CLLocationCoordinate2D, areaId: String) {
        states[areaId] = .located(coordinate)
        var cached = UserDefaults.standard.dictionary(forKey: Self.cacheKey) as? [String: [Double]] ?? [:]
        cached[areaId] = [coordinate.latitude, coordinate.longitude]
        UserDefaults.standard.set(cached, forKey: Self.cacheKey)
    }

    func forget(areaId: String) {
        states[areaId] = .unknown
        var cached = UserDefaults.standard.dictionary(forKey: Self.cacheKey) as? [String: [Double]] ?? [:]
        cached[areaId] = nil
        UserDefaults.standard.set(cached, forKey: Self.cacheKey)
    }

    func locateMissing(in areas: [ParkingArea]) async {
        guard !isLocatingAll else { return }
        isLocatingAll = true
        defer { isLocatingAll = false }

        for area in areas where coordinate(for: area.id) == nil {
            await locate(area)
        }
    }

    func locate(_ area: ParkingArea) async {
        states[area.id] = .locating

        for candidate in await candidates(for: area) {
            guard !Task.isCancelled else {
                states[area.id] = .unknown
                return
            }
            if await covers(area.id, candidate) {
                remember(candidate, areaId: area.id)
                return
            }
        }
        states[area.id] = .notFound
    }


    private func candidates(for area: ParkingArea) async -> [CLLocationCoordinate2D] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(area.name), \(area.city)"

        guard let response = try? await MKLocalSearch(request: request).start() else { return [] }

        return response.mapItems.prefix(3).flatMap { item in
            probes(around: item.location.coordinate)
        }
    }

    private func probes(around center: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        probeRadii.flatMap { radius -> [CLLocationCoordinate2D] in
            guard radius > 0 else { return [center] }
            return (0..<probeBearings).map { index in
                let angle = 2 * Double.pi * Double(index) / Double(probeBearings)
                return offset(center, north: radius * cos(angle), east: radius * sin(angle))
            }
        }
    }

    private func offset(
        _ coordinate: CLLocationCoordinate2D,
        north: CLLocationDistance,
        east: CLLocationDistance
    ) -> CLLocationCoordinate2D {
        let metersPerDegree = 111_320.0
        let latitude = coordinate.latitude + north / metersPerDegree
        let longitude = coordinate.longitude
            + east / (metersPerDegree * cos(coordinate.latitude * .pi / 180))
        return .init(latitude: latitude, longitude: longitude)
    }

    private func covers(_ areaId: String, _ coordinate: CLLocationCoordinate2D) async -> Bool {
        let result = await service.discover(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        guard case .success(let area) = result else { return false }
        return area?.id == areaId
    }
}

#endif
