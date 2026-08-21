//
//  AreaService.swift
//  EstacioneAqui
//


import Foundation

protocol AreaServicing {
    func areas() async -> NetworkResult<[ParkingAreaNetwork]>
    func area(id: String) async -> NetworkResult<ParkingAreaNetwork>
    func discover(latitude: Double, longitude: Double) async -> NetworkResult<ParkingAreaNetwork?>
}

struct AreaService: AreaServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func areas() async -> NetworkResult<[ParkingAreaNetwork]> {
        await client.request(.get, "/api/v1/areas", authenticated: true)
    }

    func area(id: String) async -> NetworkResult<ParkingAreaNetwork> {
        await client.request(.get, "/api/v1/areas/\(id)", authenticated: true)
    }

    func discover(latitude: Double, longitude: Double) async -> NetworkResult<ParkingAreaNetwork?> {
        let result: NetworkResult<ParkingAreaNetwork> = await client.request(
            .get,
            "/api/v1/areas/discover",
            query: [
                "latitude": String(latitude),
                "longitude": String(longitude),
            ],
            authenticated: true
        )
        switch result {
        case .success(let area):
            return .success(area)
        case .error(.notFound):
            return .success(nil)
        case .error(let failure):
            return .error(failure)
        }
    }
}
