//
//  EliminarCuentaView.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 1/6/26.
//


struct EliminarCuentaView: View {
    var onBack: (() -> Void)? = nil
    var onAccountDeleted: (() -> Void)? = nil

    private let clienteId = UserDefaults.standard.string(forKey: "profileId") ?? ""

    @StateObject private var viewModel = DeleteUserViewModel(
        deleteUserRepository: DeleteUserRepository()
    )

    @State private var confirmText: String = ""
    @State private var showFinalConfirm: Bool = false
    @State private var isVisible = false

    private var isConfirmValid: Bool {
        confirmText == "ELIMINAR"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.10, blue: 0.10),
                    Color(red: 0.04, green: 0.04, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    HStack {
                        Button(action: { onBack?() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(12)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.4), value: isVisible)

                    Spacer().frame(height: 12)

                    headerSection
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : -30)
                        .animation(.easeOut(duration: 0.6).delay(0.1), value: isVisible)

                    Spacer().frame(height: 24)

                    warningSection
                        .padding(.horizontal, 16)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 40)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                    Spacer().frame(height: 16)

                    confirmField
                        .padding(.horizontal, 16)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 40)
                        .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)

                    Spacer().frame(height: 12)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.91, green: 0.44, blue: 0.44))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .transition(.opacity)
                    }

                    Spacer().frame(height: 24)

                    actionButtons
                        .padding(.horizontal, 16)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 40)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                    Spacer().frame(height: 32)
                }
            }

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFinalConfirm) {
            FinalConfirmSheet(
                onConfirm: { performDelete() },
                onCancel:  { showFinalConfirm = false }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.isDeleted) { deleted in
            if deleted {
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "profileId")
                UserDefaults.standard.removeObject(forKey: "profileName")
                UserDefaults.standard.removeObject(forKey: "profileEmail")
                onAccountDeleted?()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isVisible = true
            }
        }
    }

    // ── Subviews ──────────────────────────────────────────────────────────────

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.25, green: 0.08, blue: 0.08))
                    .frame(width: 72, height: 72)
                Text("🚫")
                    .font(.system(size: 36))
            }

            Text("Eliminar mi cuenta")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            Text("Esta acción es permanente e irreversible")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var warningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Qué se eliminará?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.91, green: 0.44, blue: 0.44))

            VStack(alignment: .leading, spacing: 10) {
                deleteItem("Tu perfil y datos personales")
                deleteItem("Historial de pagos y cuotas")
                deleteItem("Acceso a tus propiedades")
                deleteItem("Toda tu información almacenada")
            }
        }
        .padding(16)
        .background(Color(red: 0.16, green: 0.08, blue: 0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.42, green: 0.13, blue: 0.13), lineWidth: 0.5)
        )
        .cornerRadius(14)
    }

    private func deleteItem(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.91, green: 0.44, blue: 0.44))
                .frame(width: 20, height: 20)
                .background(Color(red: 0.30, green: 0.10, blue: 0.10))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.65))
        }
    }

    private var confirmField: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Text("Escribe")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                Text("ELIMINAR")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(red: 0.91, green: 0.44, blue: 0.44))
                Text("para confirmar")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }

            TextField("", text: $confirmText)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white)
                .autocapitalization(.allCharacters)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isConfirmValid
                                ? Color(red: 0.75, green: 0.22, blue: 0.22)
                                : Color.white.opacity(0.15),
                            lineWidth: 0.5
                        )
                )
                .cornerRadius(12)
        }
        .padding(16)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(14)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                guard isConfirmValid else { return }
                showFinalConfirm = true
            }) {
                Text("Eliminar mi cuenta")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isConfirmValid ? .white : .white.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        isConfirmValid
                            ? Color(red: 0.75, green: 0.22, blue: 0.17)
                            : Color(red: 0.29, green: 0.10, blue: 0.10)
                    )
                    .cornerRadius(14)
                    .animation(.easeInOut(duration: 0.25), value: isConfirmValid)
            }
            .disabled(!isConfirmValid || viewModel.isLoading)

            Button(action: { onBack?() }) {
                Text("Cancelar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
                Text("Eliminando cuenta...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .cornerRadius(20)
        }
        .transition(.opacity)
    }

    // ── Lógica ────────────────────────────────────────────────────────────────

    private func performDelete() {
        showFinalConfirm = false
        Task {
            try? await viewModel.deleteUser(id: clienteId)
        }
    }
}