//
//  LoginView.swift
//  EstacioneAqui
//


import SwiftUI

struct LoginView: View {
    var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var hasSubmitted = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    private var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && email.contains("@")
    }

    private var isPasswordValid: Bool {
        !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 24) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .foregroundStyle(Color.primaryBlue)
                                .frame(width: 100, height: 100)
                                .shadow(color: .primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)

                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 55, height: 55)
                                .foregroundStyle(Color.onPrimaryBlue)
                        }

                        VStack(spacing: 8) {
                            Text("EstacioneAqui")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("app_tagline")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 48)

                    if let error = viewModel.error {
                        ErrorBanner(error: error)
                            .padding(.bottom, 24)
                    }

                    VStack(spacing: 24) {
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "email",
                            text: $email,
                            isValid: isEmailValid,
                            isUserSubmitted: hasSubmitted,
                            errorMessage: email.isEmpty ? "enter_your_email" : "invalid_email"
                        )
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = .password }

                        CustomSecureField(
                            icon: "lock",
                            placeholder: "password",
                            text: $password,
                            isValid: isPasswordValid,
                            isPassSubmitted: hasSubmitted,
                            errorMessage: "password_required"
                        )
                        .textContentType(.password)
                        .submitLabel(.go)
                        .focused($focusedField, equals: .password)
                        .onSubmit { submit() }

                    }
                    .padding(.bottom, 24)

                    PrimaryButton(
                        title: "sign_in",
                        isLoading: viewModel.isAuthenticating,
                        action: submit
                    )
                    .padding(.bottom, 24)

                    HStack {
                        Rectangle()
                            .fill(.tertiary)
                            .frame(height: 1)

                        Text("or")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Rectangle()
                            .fill(.tertiary)
                            .frame(height: 1)
                    }
                    .padding(.bottom, 24)

                    NavigationLink {
                        RegisterView(viewModel: viewModel)
                    } label: {
                        HStack(spacing: 4) {
                            Text("no_account_question")
                                .foregroundStyle(.secondary)

                            Text("sign_up")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.primaryBlue)
                        }
                        .font(.subheadline)
                    }
                    .buttonStyle(.plain)

                    Text("copyright \(String(Calendar.current.component(.year, from: Date())))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 48)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .animation(.easeInOut(duration: 0.2), value: viewModel.error)
            .onAppear { viewModel.error = nil }
        }
    }

    private func submit() {
        hasSubmitted = true
        guard isEmailValid, isPasswordValid else { return }
        focusedField = nil
        Task {
            await viewModel.login(email: email, password: password)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
