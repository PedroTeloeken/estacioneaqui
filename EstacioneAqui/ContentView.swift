//
//  ContentView.swift
//  EstacioneAqui
//  Created by Pedro Teloeken on 18/06/26.
//


import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .controlSize(.large)
            case .signedOut:
                LoginView(viewModel: viewModel)
            case let .signedIn(user):
                MainTabView(user: user)
            }
        }
        .animation(.default, value: viewModel.state)
        .tint(.primaryBlue)
        .environment(viewModel)
        .pulseConsoleOnShake()
        .task {
            await viewModel.bootstrap()
        }
    }
}

#Preview {
    ContentView()
}
