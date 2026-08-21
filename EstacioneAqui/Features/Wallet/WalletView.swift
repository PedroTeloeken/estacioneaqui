//
//  WalletView.swift
//  EstacioneAqui
//


import SwiftUI

struct WalletView: View {
    @State private var viewModel = WalletViewModel()
    @State private var isPresentingTopUp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    balanceCard

                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                    }

                    transactionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("tab_wallet")
            .navigationDestination(for: WalletTransaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .sheet(isPresented: $isPresentingTopUp) {
                TopUpSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    private var balanceCard: some View {
        BalanceCard(
            balance: viewModel.wallet?.balance,
            isLoading: viewModel.isLoading,
            onTopUp: { isPresentingTopUp = true }
        )
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("transactions")
                .font(.headline)

            if viewModel.transactions.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "list.bullet.rectangle",
                    title: "no_transactions",
                    message: "no_transactions_message"
                )
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.transactions) { transaction in
                        NavigationLink(value: transaction) {
                            TransactionRow(transaction: transaction)
                        }
                        .buttonStyle(.plain)
                        .task {
                            await viewModel.loadMoreIfNeeded(current: transaction)
                        }

                        if transaction.id != viewModel.transactions.last?.id {
                            Divider()
                                .padding(.leading, 66)
                        }
                    }

                    if viewModel.isLoadingPage {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

#Preview {
    WalletView()
}
