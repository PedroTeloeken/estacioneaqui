//
//  VehiclesListView.swift
//  EstacioneAqui
//


import SwiftUI

struct VehiclesListView: View {
    @State private var viewModel = VehiclesViewModel()
    @State private var isPresentingCreateForm = false
    @State private var editingVehicle: Vehicle?

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.vehicles.isEmpty {
                VStack(spacing: 8) {
                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                            .padding(.horizontal, 20)
                    }

                    EmptyStateView(
                        icon: "car.fill",
                        title: "no_vehicles",
                        message: "no_vehicles_message"
                    )
                }
            } else {
                vehicleList
            }
        }
        .navigationTitle("my_vehicles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("add", systemImage: "plus") {
                    isPresentingCreateForm = true
                }
            }
        }
        .sheet(isPresented: $isPresentingCreateForm, onDismiss: { viewModel.error = nil }) {
            VehicleFormView(viewModel: viewModel)
        }
        .sheet(item: $editingVehicle, onDismiss: { viewModel.error = nil }) { vehicle in
            VehicleFormView(viewModel: viewModel, editingVehicle: vehicle)
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private var vehicleList: some View {
        List {
            if let error = viewModel.error {
                ErrorBanner(error: error)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.vehicles) { vehicle in
                VehicleRow(vehicle: vehicle)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingVehicle = vehicle
                    }
                    .swipeActions(edge: .trailing) {
                        Button("remove", systemImage: "trash", role: .destructive) {
                            Task { await viewModel.delete(vehicle) }
                        }
                    }
                    .swipeActions(edge: .leading) {
                        if !vehicle.primaryVehicle {
                            Button("primary", systemImage: "star.fill") {
                                Task { await viewModel.setPrimary(vehicle) }
                            }
                            .tint(.primaryBlue)
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.vehicles)
    }
}

#Preview {
    NavigationStack {
        VehiclesListView()
    }
}
