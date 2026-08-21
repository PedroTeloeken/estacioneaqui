//
//  VehiclesViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class VehiclesViewModel {

    private(set) var vehicles: [Vehicle] = []
    private(set) var isLoading = false
    private(set) var isSaving = false
    var error: NetworkError?

    @ObservationIgnored private let service: VehicleServicing

    init(service: VehicleServicing = VehicleService()) {
        self.service = service
    }

    func load() async {
        isLoading = vehicles.isEmpty
        defer { isLoading = false }

        switch await service.list() {
        case .success(let vehicles):
            self.vehicles = vehicles
                .map { $0.toDomain() }
                .sorted { $0.primaryVehicle && !$1.primaryVehicle }
            error = nil
        case .error(let failure):
            error = failure
        }
    }

    func save(plate: String, model: String?, color: String?, primaryVehicle: Bool, editing id: String?) async -> Bool {
        guard !isSaving else { return false }
        error = nil
        isSaving = true
        defer { isSaving = false }

        let result: NetworkResult<VehicleNetwork>
        if let id {
            result = await service.update(
                id: id,
                UpdateVehicleRequest(plate: plate, model: model, color: color, primaryVehicle: primaryVehicle)
            )
        } else {
            result = await service.create(
                CreateVehicleRequest(plate: plate, model: model, color: color, primaryVehicle: primaryVehicle)
            )
        }

        switch result {
        case .success:
            await load()
            return true
        case .error(let failure):
            error = failure
            return false
        }
    }

    func delete(_ vehicle: Vehicle) async {
        switch await service.delete(id: vehicle.id) {
        case .success:
            await load()
        case .error(let failure):
            error = failure
        }
    }

    func setPrimary(_ vehicle: Vehicle) async {
        guard !vehicle.primaryVehicle else { return }
        switch await service.setPrimary(id: vehicle.id) {
        case .success:
            await load()
        case .error(let failure):
            error = failure
        }
    }
}
