//
//  HistoryView.swift
//  EstacioneAqui
//


import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.sessions.isEmpty {
                    emptyOrError
                } else {
                    sessionsList
                }
            }
            .navigationTitle("tab_activity")
            .searchable(text: $viewModel.plateFilter, prompt: "search_by_plate")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .task {
                await viewModel.refresh()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: viewModel.plateFilter) {
                Task { await viewModel.refresh() }
            }
            .onChange(of: viewModel.statusFilter) {
                Task { await viewModel.refresh() }
            }
            .onChange(of: viewModel.period) {
                Task { await viewModel.refresh() }
            }
        }
    }

    @ViewBuilder
    private var emptyOrError: some View {
        if let error = viewModel.error {
            VStack(spacing: 16) {
                ErrorBanner(error: error)

                Button("try_again") {
                    Task { await viewModel.refresh() }
                }
                .font(.subheadline.weight(.semibold))
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            EmptyStateView(
                icon: "clock.arrow.circlepath",
                title: "no_sessions",
                message: "no_sessions_message"
            )
        }
    }

    private var sessionsList: some View {
        List {
            if let error = viewModel.error {
                ErrorBanner(error: error)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(viewModel.sessions) { session in
                SessionHistoryRow(session: session)
                    .task {
                        await viewModel.loadMoreIfNeeded(current: session)
                    }
            }

            if viewModel.isLoadingPage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: viewModel.sessions)
    }

    private var filterMenu: some View {
        Menu {
            Picker("status", selection: $viewModel.statusFilter) {
                Text("all").tag(ParkingStatus?.none)
                ForEach(ParkingStatus.allCases, id: \.self) { status in
                    Text(status.label).tag(ParkingStatus?.some(status))
                }
            }

            Picker("period", selection: $viewModel.period) {
                ForEach(HistoryViewModel.Period.allCases) { period in
                    Text(period.label).tag(period)
                }
            }
        } label: {
            Label("filters", systemImage: hasActiveFilters
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
    }

    private var hasActiveFilters: Bool {
        viewModel.statusFilter != nil || viewModel.period != .all
    }
}

#Preview {
    HistoryView()
}
