//
//  MainTabView.swift
//  EstacioneAqui
//


import SwiftUI

struct MainTabView: View {
    let user: UserProfile

    @State private var sessionStore = ActiveSessionStore()
    @State private var isShowingActiveSession = false
    @State private var pendingAction: ParkingDeepLink?
    @State private var selectedTab: TabItem = .map
    @Environment(\.scenePhase) private var scenePhase

    private enum TabItem: Hashable {
        case map, wallet, activity, profile
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            Tab("tab_map", systemImage: "map.fill", value: TabItem.map) {
                MapHomeView()
            }
            Tab("tab_wallet", systemImage: "wallet.bifold.fill", value: TabItem.wallet) {
                WalletView()
            }
            Tab("tab_activity", systemImage: "clock.arrow.circlepath", value: TabItem.activity) {
                HistoryView()
            }
            Tab("tab_profile", systemImage: "person.crop.circle", value: TabItem.profile) {
                ProfileView(user: user)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    var body: some View {
        Group {
            if let session = sessionStore.session {
                tabs.tabViewBottomAccessory {
                    ActiveSessionMiniBar(session: session, anchorEnd: sessionStore.anchorEnd)
                        .onTapGesture {
                            isShowingActiveSession = true
                        }
                }
            } else {
                tabs
            }
        }
        .sheet(isPresented: $isShowingActiveSession) {
            pendingAction = nil
        } content: {
            ActiveSessionView(pendingAction: pendingAction)
        }
        .environment(sessionStore)
        .onOpenURL { url in
            guard let action = ParkingDeepLink(url: url) else { return }
            pendingAction = action
            isShowingActiveSession = true
        }
        .task {
            await sessionStore.refresh()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await sessionStore.refresh() }
            }
        }
        .task(id: sessionStore.anchorEnd) {
            guard sessionStore.session?.status == .active else { return }

            let interval = sessionStore.anchorEnd.timeIntervalSinceNow
            try? await Task.sleep(for: .seconds(max(15, interval + 1)))
            guard !Task.isCancelled else { return }
            await sessionStore.refresh()
        }
    }
}

#Preview {
    MainTabView(
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
