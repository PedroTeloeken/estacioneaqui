//
//  StartParkingSheet.swift
//  EstacioneAqui
//


import SwiftUI
import CoreLocation

struct StartParkingSheet: View {
    let coordinate: CLLocationCoordinate2D

    @State private var viewModel: StartParkingViewModel
    @State private var vehiclesViewModel = VehiclesViewModel()
    @State private var walletViewModel = WalletViewModel()
    @State private var isPresentingVehicleForm = false
    @State private var isPresentingTopUp = false

    @Environment(ActiveSessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss

    init(area: ParkingArea, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _viewModel = State(initialValue: StartParkingViewModel(area: area))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                    }

                    areaSummary
                    vehicleSection
                    durationSection
                    paymentSection
                }
                .padding(20)
            }
            .safeAreaInset(edge: .bottom) {
                payBar
            }
            .navigationTitle("park")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPresentingVehicleForm, onDismiss: {
                Task { await viewModel.load() }
            }) {
                VehicleFormView(viewModel: vehiclesViewModel)
            }
            .sheet(isPresented: $isPresentingTopUp, onDismiss: {
                Task { await viewModel.reloadWallet() }
            }) {
                TopUpSheet(viewModel: walletViewModel)
            }
            .task {
                await viewModel.load()
            }
        }
        .presentationDetents([.large])
    }


    private var areaSummary: some View {
        HStack(spacing: 13) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 46, height: 46)
                .background(Color.primaryBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.area.name)
                    .font(.headline)

                Text("blue_zone_city \(viewModel.area.city)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.primaryBlue)
            }
        }
    }

    private var vehicleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "your_vehicle")

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else if viewModel.vehicles.isEmpty {
                VStack(spacing: 12) {
                    Text("no_vehicles_yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("add_vehicle", systemImage: "plus") {
                        isPresentingVehicleForm = true
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.vehicles) { vehicle in
                            VehiclePickerCard(
                                vehicle: vehicle,
                                isSelected: vehicle.id == viewModel.selectedVehicleId,
                                onTap: { viewModel.selectedVehicleId = vehicle.id }
                            )
                        }

                        Button {
                            isPresentingVehicleForm = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(Color.primaryBlue)
                                .frame(width: 50, height: 66)
                                .glassEffect(.regular, in: .rect(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.tertiary, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("add_vehicle")
                    }
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "duration")

            DurationChips(options: viewModel.durationOptions, selection: $viewModel.minutes)

            Text("until \(viewModel.endDate.formatted(date: .omitted, time: .shortened))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "payment")

            HStack(spacing: 13) {
                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.primaryBlue)
                    .frame(width: 42, height: 42)
                    .background(Color.primaryBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("wallet_balance")
                        .font(.subheadline.weight(.semibold))

                    Text(viewModel.balance.brl)
                        .font(.caption)
                        .foregroundStyle(viewModel.hasSufficientBalance ? Color.secondary : Color.red)
                        .contentTransition(.numericText())
                }

                Spacer()

                if !viewModel.hasSufficientBalance {
                    Text("insufficient_balance")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
    }

    private var payBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 1) {
                Text("total")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(viewModel.price.brl)
                    .font(.title3.bold())
                    .contentTransition(.numericText())
            }

            if viewModel.hasSufficientBalance {
                PrimaryButton(
                    title: "confirm_and_park",
                    isLoading: viewModel.isStarting,
                    isDisabled: viewModel.selectedVehicleId == nil,
                    action: confirm
                )
            } else {
                PrimaryButton(title: "add_balance") {
                    isPresentingTopUp = true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
        .animation(.easeInOut(duration: 0.2), value: viewModel.price)
    }

    private func confirm() {
        Task {
            if let session = await viewModel.start(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ) {
                sessionStore.adopt(session)
                dismiss()
            }
        }
    }
}

private struct SectionLabel: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .textCase(.uppercase)
            .font(.caption.weight(.bold))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    StartParkingSheet(
        area: ParkingArea(
            id: "1",
            name: "Centro",
            city: "Blumenau",
            pricePerHour: 3,
            maxMinutes: 120,
            active: true,
            zone: nil,
            createdAt: nil,
            updatedAt: nil
        ),
        coordinate: CLLocationCoordinate2D(latitude: -26.9175, longitude: -49.0716)
    )
    .environment(ActiveSessionStore())
}
