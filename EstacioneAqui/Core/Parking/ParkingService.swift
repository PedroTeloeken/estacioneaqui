//
//  ParkingService.swift
//  EstacioneAqui
//


import Foundation

protocol ParkingServicing {
    func start(vehicleId: String, latitude: Double, longitude: Double, minutes: Int) async -> NetworkResult<ParkingSessionNetwork>
    func extend(id: String, additionalMinutes: Int) async -> NetworkResult<ParkingSessionNetwork>
    func finish(id: String) async -> NetworkResult<ParkingSessionNetwork>
    func active() async -> NetworkResult<ParkingSessionNetwork?>
    func history(
        startDate: Date?,
        endDate: Date?,
        plate: String?,
        status: ParkingStatusNetwork?,
        page: Int,
        size: Int
    ) async -> NetworkResult<PageResponse<ParkingSessionNetwork>>
}

struct ParkingService: ParkingServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func start(vehicleId: String, latitude: Double, longitude: Double, minutes: Int) async -> NetworkResult<ParkingSessionNetwork> {
        await client.request(
            .post,
            "/api/v1/parking/start",
            body: StartParkingRequest(
                vehicleId: vehicleId,
                latitude: latitude,
                longitude: longitude,
                minutes: minutes
            ),
            authenticated: true
        )
    }

    func extend(id: String, additionalMinutes: Int) async -> NetworkResult<ParkingSessionNetwork> {
        await client.request(
            .post,
            "/api/v1/parking/\(id)/extend",
            body: ExtendParkingRequest(additionalMinutes: additionalMinutes),
            authenticated: true
        )
    }

    func finish(id: String) async -> NetworkResult<ParkingSessionNetwork> {
        await client.request(.post, "/api/v1/parking/\(id)/finish", authenticated: true)
    }

    func active() async -> NetworkResult<ParkingSessionNetwork?> {
        let result: NetworkResult<ParkingSessionNetwork?> = await client.request(
            .get,
            "/api/v1/parking/active",
            authenticated: true
        )
        if case .error(.notFound) = result {
            return .success(nil)
        }
        return result
    }

    func history(
        startDate: Date?,
        endDate: Date?,
        plate: String?,
        status: ParkingStatusNetwork?,
        page: Int,
        size: Int
    ) async -> NetworkResult<PageResponse<ParkingSessionNetwork>> {
        await client.request(
            .get,
            "/api/v1/parking/history",
            query: [
                "dataInicial": startDate.map(Self.queryDateFormatter.string(from:)),
                "dataFinal": endDate.map(Self.queryDateFormatter.string(from:)),
                "placa": plate,
                "status": status?.rawValue,
                "page": String(page),
                "size": String(size),
            ],
            authenticated: true
        )
    }

    private static let queryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
