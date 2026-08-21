//
//  TopUpSheet.swift
//  EstacioneAqui
//


import SwiftUI

struct TopUpSheet: View {
    var viewModel: WalletViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedPreset: Decimal?
    @State private var customAmount: Decimal?
    @FocusState private var isCustomFieldFocused: Bool

    private let presets: [Decimal] = [10, 25, 50, 100]

    private var amount: Decimal? {
        selectedPreset ?? customAmount
    }

    private var isAmountValid: Bool {
        (amount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                if let error = viewModel.error {
                    ErrorBanner(error: error)
                }

                Text("how_much_add")
                    .font(.headline)

                HStack(spacing: 10) {
                    ForEach(presets, id: \.self) { preset in
                        AmountChip(
                            label: preset.brl,
                            isSelected: selectedPreset == preset
                        ) {
                            selectedPreset = preset
                            customAmount = nil
                            isCustomFieldFocused = false
                        }
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "brazilianrealsign.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(customAmount == nil ? .secondary : Color.primaryBlue)
                        .frame(width: 20)

                    TextField(
                        "other_amount",
                        value: $customAmount,
                        format: .currency(code: "BRL").locale(Locale(identifier: "pt_BR"))
                    )
                    .keyboardType(.decimalPad)
                    .focused($isCustomFieldFocused)
                    .onChange(of: isCustomFieldFocused) { _, focused in
                        if focused { selectedPreset = nil }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .glassEffect(.regular, in: .rect(cornerRadius: 14))
                .background(Color.fieldSurface, in: .rect(cornerRadius: 14))

                Spacer()

                PrimaryButton(
                    title: "add_credits",
                    isLoading: viewModel.isToppingUp,
                    isDisabled: !isAmountValid,
                    action: submit
                )
            }
            .padding(20)
            .navigationTitle("add_balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("ok") {
                        isCustomFieldFocused = false
                    }
                }
            }
            .onAppear {
                viewModel.error = nil
            }
        }
        .presentationDetents([.medium])
    }

    private func submit() {
        guard let amount, amount > 0 else { return }
        Task {
            if await viewModel.topUp(amount: amount, description: String(localized: "credits_via_app")) {
                dismiss()
            }
        }
    }
}

#Preview {
    TopUpSheet(viewModel: WalletViewModel())
}
