//
//  VehicleService.swift
//  EstacioneAqui
//


import Foundation

protocol VehicleServicing {
    func list() async -> NetworkResult<[VehicleNetwork]>
    func create(_ request: CreateVehicleRequest) async -> NetworkResult<VehicleNetwork>
    func update(id: String, _ request: UpdateVehicleRequest) async -> NetworkResult<VehicleNetwork>
    func delete(id: String) async -> NetworkResult<EmptyResponse>
    func setPrimary(id: String) async -> NetworkResult<EmptyResponse>
}

struct VehicleService: VehicleServicing {

    private let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    func list() async -> NetworkResult<[VehicleNetwork]> {
        await client.request(.get, "/api/v1/vehicles", authenticated: true)
    }

    func create(_ request: CreateVehicleRequest) async -> NetworkResult<VehicleNetwork> {
        await client.request(.post, "/api/v1/vehicles", body: request, authenticated: true)
    }

    func update(id: String, _ request: UpdateVehicleRequest) async -> NetworkResult<VehicleNetwork> {
        await client.request(.put, "/api/v1/vehicles/\(id)", body: request, authenticated: true)
    }

    func delete(id: String) async -> NetworkResult<EmptyResponse> {
        await client.request(.delete, "/api/v1/vehicles/\(id)", authenticated: true)
    }

    func setPrimary(id: String) async -> NetworkResult<EmptyResponse> {
        await client.request(.patch, "/api/v1/vehicles/\(id)/primary", authenticated: true)
    }
}
