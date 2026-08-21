//
//  CarRouteViewModel.swift
//  EstacioneAqui
//


import CoreLocation
import MapKit
import Observation

@MainActor
@Observable
final class CarRouteViewModel {

    var isCarSelected = false

    private(set) var route: MKRoute?
    private(set) var isCalculating = false
    private(set) var error: String?

    func selectCar() {
        isCarSelected = true
    }

    func calculateRoute(from origin: CLLocationCoordinate2D, to car: CLLocationCoordinate2D) async {
        guard !isCalculating else { return }
        isCalculating = true
        error = nil
        defer { isCalculating = false }

        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: origin.latitude, longitude: origin.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: car.latitude, longitude: car.longitude), address: nil)
        request.transportType = .walking

        do {
            let response = try await MKDirections(request: request).calculate()
            guard let first = response.routes.first else {
                error = String(localized: "route_not_found")
                return
            }
            route = first
        } catch {
            self.error = String(localized: "route_failed")
        }
    }

    func clear() {
        isCarSelected = false
        route = nil
        error = nil
    }

    func clearRoute() {
        route = nil
        error = nil
    }
}
