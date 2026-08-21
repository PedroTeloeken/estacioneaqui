//
//  DebugLocationOverride.swift
//  EstacioneAqui
//


#if DEBUG

import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class DebugLocationOverride {

    static let shared = DebugLocationOverride()

    struct Place: Codable, Identifiable, Hashable {
        var id: UUID = UUID()
        var name: String
        var latitude: Double
        var longitude: Double

        var coordinate: CLLocationCoordinate2D {
            .init(latitude: latitude, longitude: longitude)
        }
    }

    static let blumenauCentro = CLLocationCoordinate2D(latitude: -26.9175, longitude: -49.0716)

    private(set) var coordinate: CLLocationCoordinate2D?
    private(set) var places: [Place] = []

    var isActive: Bool { coordinate != nil }

    @ObservationIgnored
    private var continuations: [UUID: AsyncStream<CLLocationCoordinate2D?>.Continuation] = [:]

    private enum Key {
        static let coordinate = "debug.location.coordinate"
        static let places = "debug.location.places"
        static let hasChosen = "debug.location.hasChosen"
    }

    private init() {
        let stored = UserDefaults.standard.array(forKey: Key.coordinate) as? [Double]
        if let stored, stored.count == 2 {
            coordinate = CLLocationCoordinate2D(latitude: stored[0], longitude: stored[1])
        } else if !UserDefaults.standard.bool(forKey: Key.hasChosen) {
            coordinate = Self.blumenauCentro
        }
        if let data = UserDefaults.standard.data(forKey: Key.places),
           let decoded = try? JSONDecoder().decode([Place].self, from: data) {
            places = decoded
        }
    }


    func use(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        UserDefaults.standard.set(
            [coordinate.latitude, coordinate.longitude],
            forKey: Key.coordinate
        )
        UserDefaults.standard.set(true, forKey: Key.hasChosen)
        broadcast()
    }

    func clear() {
        coordinate = nil
        UserDefaults.standard.removeObject(forKey: Key.coordinate)
        UserDefaults.standard.set(true, forKey: Key.hasChosen)
        broadcast()
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: Key.hasChosen)
        use(Self.blumenauCentro)
        UserDefaults.standard.removeObject(forKey: Key.hasChosen)
    }


    func save(name: String, coordinate: CLLocationCoordinate2D) {
        places.append(
            Place(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
        persistPlaces()
    }

    func remove(atOffsets offsets: IndexSet) {
        places.remove(atOffsets: offsets)
        persistPlaces()
    }

    private func persistPlaces() {
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: Key.places)
    }


    func changes() -> AsyncStream<CLLocationCoordinate2D?> {
        let (stream, continuation) = AsyncStream<CLLocationCoordinate2D?>.makeStream()
        let id = UUID()
        continuations[id] = continuation
        continuation.yield(coordinate)
        continuation.onTermination = { _ in
            Task { @MainActor [weak self] in
                self?.continuations[id] = nil
            }
        }
        return stream
    }

    private func broadcast() {
        for continuation in continuations.values {
            continuation.yield(coordinate)
        }
    }
}

#endif
