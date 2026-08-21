//
//  RegisterView.swift
//  EstacioneAqui
//


import SwiftUI

struct RegisterView: View {
    var viewModel: AuthViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hasSubmitted = false

    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case email
        case password
        case confirmPassword
    }

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && email.contains("@")
    }

    private var isPasswordValid: Bool {
        password.count >= 6
    }

    private var isConfirmationValid: Bool {
        !confirmPassword.isEmpty && confirmPassword == password
    }

    private var isFormValid: Bool {
        isNameValid && isEmailValid && isPasswordValid && isConfirmationValid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("register_subtitle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)

                if let error = viewModel.error {
                    ErrorBanner(error: error)
                        .padding(.bottom, 24)
                }

                CustomTextField(
                    icon: "person",
                    placeholder: "your_name",
                    text: $name,
                    isValid: isNameValid,
                    isUserSubmitted: hasSubmitted,
                    errorMessage: "enter_your_name"
                )
                .textContentType(.name)
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .email }
                .padding(.bottom, 24)

                CustomTextField(
                    icon: "envelope",
                    placeholder: "email_example",
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
                .padding(.bottom, 24)

                CustomSecureField(
                    icon: "lock",
                    placeholder: "min_6_characters",
                    text: $password,
                    isValid: isPasswordValid,
                    isPassSubmitted: hasSubmitted,
                    errorMessage: "password_min_6"
                )
                .textContentType(.newPassword)
                .submitLabel(.next)
                .focused($focusedField, equals: .password)
                .onSubmit { focusedField = .confirmPassword }
                .padding(.bottom, 24)

                CustomSecureField(
                    icon: "lock",
                    placeholder: "repeat_password",
                    text: $confirmPassword,
                    isValid: isConfirmationValid,
                    isPassSubmitted: hasSubmitted,
                    errorMessage: confirmPassword.isEmpty ? "confirm_password_required" : "passwords_dont_match"
                )
                .textContentType(.newPassword)
                .submitLabel(.go)
                .focused($focusedField, equals: .confirmPassword)
                .onSubmit { submit() }
                .padding(.bottom, 36)

                PrimaryButton(
                    title: "create_account",
                    isLoading: viewModel.isAuthenticating,
                    action: submit
                )
            }
            .padding(.horizontal, 18)
        }
        .scrollDismissesKeyboard(.interactively)
        .animation(.easeInOut(duration: 0.2), value: viewModel.error)
        .onAppear { viewModel.error = nil }
        .navigationTitle("create_account")
        .navigationBarTitleDisplayMode(.large)
    }

    private func submit() {
        hasSubmitted = true
        guard isFormValid else { return }
        focusedField = nil
        Task {
            await viewModel.register(name: name, email: email, password: password)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView(viewModel: AuthViewModel())
    }
}
