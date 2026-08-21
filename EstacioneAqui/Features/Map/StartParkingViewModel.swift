//
//  StartParkingViewModel.swift
//  EstacioneAqui
//


import Foundation
import Observation

@MainActor
@Observable
final class StartParkingViewModel {

    let area: ParkingArea

    private(set) var vehicles: [Vehicle] = []
    private(set) var wallet: Wallet?
    private(set) var isLoading = false
    private(set) var isStarting = false
    var selectedVehicleId: String?
    var minutes: Int
    var error: NetworkError?

    @ObservationIgnored private let vehicleService: VehicleServicing
    @ObservationIgnored private let walletService: WalletServicing
    @ObservationIgnored private let parkingService: ParkingServicing

    init(
        area: ParkingArea,
        vehicleService: VehicleServicing = VehicleService(),
        walletService: WalletServicing = WalletService(),
        parkingService: ParkingServicing = ParkingService()
    ) {
        self.area = area
        self.minutes = min(60, area.maxMinutes)
        self.vehicleService = vehicleService
        self.walletService = walletService
        self.parkingService = parkingService
    }

    var durationOptions: [Int] {
        var options = [30, 60, 90, 120, 180, 240].filter { $0 <= area.maxMinutes }
        if options.isEmpty { options = [area.maxMinutes] }

        #if DEBUG
        options.insert(1, at: 0)
        #endif

        return options
    }

    var price: Decimal {
        area.pricePerHour * Decimal(minutes) / Decimal(60)
    }

    var balance: Decimal {
        wallet?.balance ?? 0
    }

    var hasSufficientBalance: Bool {
        balance >= price
    }

    var endDate: Date {
        .now.addingTimeInterval(TimeInterval(minutes * 60))
    }

    func load() async {
        isLoading = vehicles.isEmpty
        defer { isLoading = false }

        async let vehiclesResult = vehicleService.list()
        async let walletResult = walletService.wallet()

        switch await vehiclesResult {
        case .success(let vehicles):
            self.vehicles = vehicles
                .map { $0.toDomain() }
                .sorted { $0.primaryVehicle && !$1.primaryVehicle }
            if selectedVehicleId == nil {
                selectedVehicleId = self.vehicles.first(where: \.primaryVehicle)?.id ?? self.vehicles.first?.id
            }
            error = nil
        case .error(let failure):
            error = failure
        }

        switch await walletResult {
        case .success(let wallet):
            self.wallet = wallet.toDomain()
        case .error(let failure):
            error = failure
        }
    }

    func reloadWallet() async {
        if case .success(let wallet) = await walletService.wallet() {
            self.wallet = wallet.toDomain()
        }
    }

    func start(latitude: Double, longitude: Double) async -> ParkingSession? {
        guard let selectedVehicleId, !isStarting else { return nil }
        error = nil
        isStarting = true
        defer { isStarting = false }

        switch await parkingService.start(
            vehicleId: selectedVehicleId,
            latitude: latitude,
            longitude: longitude,
            minutes: minutes
        ) {
        case .success(let session):
            return session.toDomain()
        case .error(let failure):
            error = failure
            return nil
        }
    }
}
