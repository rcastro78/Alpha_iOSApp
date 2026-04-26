import SwiftUI

struct LoginView: View {
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var onLoginSuccess: (() -> Void)? = nil

    @StateObject private var viewModel = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    @State private var showRegister = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fondo difuminado
                Image("fondo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .blur(radius: 6)
                    .clipped()
                    .ignoresSafeArea()

                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {

                        // ── Logo ─────────────────────────────────────────
                        Image("logo_alpha_02")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .padding(.top, 80)
                            .padding(.bottom, 40)

                        // ── Card ─────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 20) {

                            Text("Iniciar Sesión")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)

                            // Campo email
                            fieldLabel("Correo electrónico")
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 20)
                                TextField("", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundColor(.white)
                                    .focused($focusedField, equals: .email)
                                    .tint(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )

                            // Campo contraseña
                            fieldLabel("Contraseña")
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 20)

                                if passwordVisible {
                                    TextField("", text: $password)
                                        .autocapitalization(.none)
                                        .autocorrectionDisabled()
                                        .foregroundColor(.white)
                                        .focused($focusedField, equals: .password)
                                        .tint(.white)
                                } else {
                                    SecureField("", text: $password)
                                        .foregroundColor(.white)
                                        .tint(.white)
                                        .focused($focusedField, equals: .password)
                                }

                                Button(action: { passwordVisible.toggle() }) {
                                    Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )

                            // Olvidé contraseña
                            Text("¿Olvidaste tu contraseña?, comunícate al 2254-8000 para recuperar tu contraseña.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.75))
                                .fixedSize(horizontal: false, vertical: true)

                            // Botón login
                            Button(action: login) {
                                ZStack {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.black)
                                    } else {
                                        Text("Iniciar Sesión")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.white)
                                .cornerRadius(14)
                            }
                            .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty)
                            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)

                            // ── Divider + Registro ────────────────────────
                            Divider()
                                .background(Color.white.opacity(0.2))

                            Button(action: { showRegister = true }) {
                                VStack(spacing: 4) {
                                    Text("¿No tienes cuenta?")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Crear cuenta")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .underline()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding(28)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12).opacity(0.92))
                        .cornerRadius(24)
                        .padding(.horizontal, 20)

                        // Footer
                        Text("TEC101")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearData() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView(onBackToLogin: { showRegister = false })
        }
    }

    // ── Helper label ──────────────────────────────────────────────────────────
    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.bottom, -12)
    }

    // ── Login action ──────────────────────────────────────────────────────────
    private func login() {
        focusedField = nil

        Task {
            do {
                viewModel.isLoading = true
                defer { viewModel.isLoading = false }

                // 1. Login
                let response = try await viewModel.iniciarSesion(email: email, password: password)
                let userId = response.user.id
                UserDefaults.standard.set(userId, forKey: "userId")

                // 2. Perfil
                async let profileTask: ProfileResponse = viewModel.recoverProfile(userId: userId)
                let profile = try await profileTask

                // 3. Guardar perfil
                UserDefaults.standard.set(profile.profile.nombre,    forKey: "profileName")
                UserDefaults.standard.set(profile.profile.telefono,  forKey: "userPhone")
                UserDefaults.standard.set(profile.profile.id,        forKey: "profileId")
                UserDefaults.standard.set(profile.profile.documento, forKey: "documento")

                onLoginSuccess?()

            } catch {
                // errorMessage ya fue seteado dentro del ViewModel
            }
        }
    }
}
