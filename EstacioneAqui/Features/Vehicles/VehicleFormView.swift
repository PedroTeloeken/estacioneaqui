//
//  VehicleFormView.swift
//  EstacioneAqui
//


import SwiftUI

struct VehicleFormView: View {
    var viewModel: VehiclesViewModel
    let editingVehicle: Vehicle?

    @Environment(\.dismiss) private var dismiss

    @State private var plate: String
    @State private var model: String
    @State private var color: String
    @State private var primaryVehicle: Bool
    @State private var hasSubmitted = false

    init(viewModel: VehiclesViewModel, editingVehicle: Vehicle? = nil) {
        self.viewModel = viewModel
        self.editingVehicle = editingVehicle
        _plate = State(initialValue: editingVehicle?.plate ?? "")
        _model = State(initialValue: editingVehicle?.model ?? "")
        _color = State(initialValue: editingVehicle?.color ?? "")
        _primaryVehicle = State(initialValue: editingVehicle?.primaryVehicle ?? false)
    }

    private var normalizedPlate: String {
        plate.replacingOccurrences(of: "-", with: "").uppercased()
    }

    private var isPlateValid: Bool {
        normalizedPlate.range(of: "^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$", options: .regularExpression) != nil
    }

    private var title: LocalizedStringKey {
        editingVehicle == nil ? "new_vehicle" : "edit_vehicle"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                    }

                    CustomTextField(
                        icon: "licenseplate",
                        placeholder: "plate_placeholder",
                        text: $plate,
                        isValid: isPlateValid,
                        isUserSubmitted: hasSubmitted,
                        errorMessage: plate.isEmpty ? "enter_plate" : "invalid_plate",
                        autocapitalization: .characters
                    )

                    CustomTextField(
                        icon: "car",
                        placeholder: "model_optional",
                        text: $model,
                        isValid: true,
                        isUserSubmitted: false,
                        errorMessage: ""
                    )

                    CustomTextField(
                        icon: "paintpalette",
                        placeholder: "color_optional",
                        text: $color,
                        isValid: true,
                        isUserSubmitted: false,
                        errorMessage: ""
                    )

                    Toggle(isOn: $primaryVehicle) {
                        Label("primary_vehicle", systemImage: "star.fill")
                            .foregroundStyle(.primary)
                    }
                    .tint(.primaryBlue)
                    .padding(.horizontal, 4)

                    PrimaryButton(
                        title: editingVehicle == nil ? "register" : "save",
                        isLoading: viewModel.isSaving,
                        action: submit
                    )
                }
                .padding(20)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.error = nil
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func submit() {
        hasSubmitted = true
        guard isPlateValid else { return }

        let trimmedModel = model.trimmingCharacters(in: .whitespaces)
        let trimmedColor = color.trimmingCharacters(in: .whitespaces)

        Task {
            let saved = await viewModel.save(
                plate: normalizedPlate,
                model: trimmedModel.isEmpty ? nil : trimmedModel,
                color: trimmedColor.isEmpty ? nil : trimmedColor,
                primaryVehicle: primaryVehicle,
                editing: editingVehicle?.id
            )
            if saved {
                dismiss()
            }
        }
    }
}

#Preview {
    VehicleFormView(viewModel: VehiclesViewModel())
}
