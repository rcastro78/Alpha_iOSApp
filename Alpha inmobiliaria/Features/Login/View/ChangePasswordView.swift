//
//  ChangePasswordView.swift
//  Alpha inmobiliaria
//

import SwiftUI

struct ChangePasswordView: View {
    var onBackToLogin: (() -> Void)? = nil

    @StateObject private var passChangeVM = PasswordChangeViewModel(repository: PasswordChangeRepository())

    @State private var email           = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var tempPassword    = ""
    @State private var newPassword     = ""
    @State private var confirmPassword = ""

    @State private var tempVisible     = false
    @State private var newVisible      = false
    @State private var confirmVisible  = false

    @State private var isLoading       = false
    @State private var isVisible       = false
    @State private var showSuccess     = false
    @State private var alertMessage    = ""
    @State private var showAlert       = false

    private var passwordMismatch: Bool {
        !confirmPassword.isEmpty && newPassword != confirmPassword
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x1A1A1A), Color(hex: 0x0A0A0A), .black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // Back button
                    HStack {
                        Button(action: { onBackToLogin?() }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(8)
                        }
                        Spacer()
                    }

                    Spacer().frame(height: 20)

                    // Header animado
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0x1F1F1F))
                                .frame(width: 96, height: 96)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }

                        Text("Cambiar contraseña")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)

                        Text("Ingresa tu contraseña temporal y define\nuna nueva contraseña segura")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -40)
                    .animation(.easeOut(duration: 0.6), value: isVisible)

                    Spacer().frame(height: 28)

                    // Card del formulario
                    VStack(spacing: 16) {
                        // Correo (deshabilitado)
                        DarkTextField(
                            text: .constant(email),
                            placeholder: "Correo electrónico",
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        .disabled(true)
                        .opacity(0.5)

                        // Contraseña temporal
                        DarkSecureField(
                            text: $tempPassword,
                            placeholder: "Contraseña temporal",
                            isVisible: $tempVisible
                        )

                        // Nueva contraseña
                        DarkSecureField(
                            text: $newPassword,
                            placeholder: "Nueva contraseña",
                            isVisible: $newVisible
                        )

                        // Confirmar contraseña
                        DarkSecureField(
                            text: $confirmPassword,
                            placeholder: "Confirmar contraseña",
                            isVisible: $confirmVisible,
                            isError: passwordMismatch,
                            errorMessage: passwordMismatch ? "Las contraseñas no coinciden" : nil
                        )

                        // Botón principal
                        Button(action: handleChangePassword) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Cambiar contraseña")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isLoading)

                        // Volver al login
                        Button(action: { onBackToLogin?() }) {
                            Text("Volver al inicio de sesión")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(28)
                    .background(Color(hex: 0x1F1F1F))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 40)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                    Spacer().frame(height: 24)

                    Text("TEC101")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isVisible = true }
        }
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("¡Contraseña actualizada!", isPresented: $showSuccess) {
            Button("Entendido") { onBackToLogin?() }
        } message: {
            Text("Tu contraseña ha sido cambiada correctamente. Ya puedes iniciar sesión.")
        }
    }

    // MARK: - Validación y cambio de contraseña

    private func handleChangePassword() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard !tempPassword.isBlank, !newPassword.isBlank, !confirmPassword.isBlank else {
            showAlert(message: "Completa todos los campos")
            return
        }
        guard newPassword == confirmPassword else {
            showAlert(message: "Las contraseñas no coinciden")
            return
        }

        isLoading = true

        Task {
            do {
                _ = try await passChangeVM.passChange(
                    email: email,
                    tempPassword: tempPassword,
                    newPassword: newPassword
                )
                isLoading = false
                showSuccess = true
            } catch {
                isLoading = false
                showAlert(message: "Ha ocurrido un error")
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}