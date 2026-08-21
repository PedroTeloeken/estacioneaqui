//
//  ProfileView.swift
//  EstacioneAqui
//


import SwiftUI

struct ProfileView: View {
    let user: UserProfile

    @Environment(AuthViewModel.self) private var authViewModel
    @State private var viewModel = ProfileViewModel()
    @State private var isConfirmingSignOut = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                    }

                    stats

                    links
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("tab_profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("sign_out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                        isConfirmingSignOut = true
                    }
                }
            }
            .confirmationDialog("sign_out_question", isPresented: $isConfirmingSignOut, titleVisibility: .visible) {
                Button("sign_out", role: .destructive) {
                    authViewModel.signOut()
                }
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            AsyncImage(url: user.profilePicture.flatMap(URL.init(string:))) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 88, height: 88)
            .clipShape(Circle())

            VStack(spacing: 2) {
                Text(user.name)
                    .font(.title3.bold())
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var stats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("summary_heading")
                .font(.headline)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if let summary = viewModel.summary {
                HStack(spacing: 12) {
                    StatTile(icon: "wallet.bifold.fill", title: "balance", value: summary.balance.brl)
                    StatTile(icon: "calendar", title: "spent_this_month", value: summary.monthlySpent.brl)
                }
                HStack(spacing: 12) {
                    StatTile(
                        icon: "parkingsign.circle.fill",
                        title: "sessions",
                        value: "\(summary.totalSessions)"
                    )
                    StatTile(
                        icon: "car.fill",
                        title: "primary_vehicle",
                        value: summary.primaryVehicle?.plate ?? "—"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var links: some View {
        VStack(spacing: 0) {
            NavigationLink {
                VehiclesListView()
            } label: {
                ProfileLinkRow(icon: "car.fill", title: "my_vehicles")
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 64)

            NavigationLink {
                NotificationsView()
            } label: {
                ProfileLinkRow(icon: "bell.fill", title: "notifications")
            }
            .buttonStyle(.plain)

            #if DEBUG
            Divider()
                .padding(.leading, 64)

            NavigationLink {
                DebugLocationView()
            } label: {
                ProfileLinkRow(icon: "location.fill.viewfinder", title: "Localização (debug)")
            }
            .buttonStyle(.plain)
            #endif
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProfileView(
        user: UserProfile(
            id: "1",
            name: "Pedro Teloeken",
            email: "pedro@example.com",
            profilePicture: nil,
            createdAt: nil
        )
    )
    .environment(AuthViewModel())
}
