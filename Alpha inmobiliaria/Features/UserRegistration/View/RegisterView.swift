//
//  ProyectoResponseItem.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//


import SwiftUI

// MARK: - Models (ajusta a los tuyos reales)
// struct ProyectoResponseItem: Codable, Identifiable, Hashable {
//     let id: String
//     let nombre: String
//     let sap_id_proyecto: String?
//     let direccion: String?
// }

// MARK: - RegisterView

struct RegisterView: View {
    var onBackToLogin: (() -> Void)? = nil

    /*
     @StateObject private var inmuebleViewModel = InmuebleViewModel(
         inmuebleRepository: InmuebleRepository()
     )
     */
    
    @StateObject private var registerVM     = NewClientRegisterSAPViewModel()
    @StateObject private var userRegisterVM = ClientRegisterViewModel(repository: ClientRegisterRepository())
    @StateObject private var proyectoVM     = ProyectoViewModel(repository: ProyectoRepository())

    // Campos del formulario
    @State private var nombre            = ""
    @State private var apellido          = ""
    @State private var email             = ""
    @State private var telefono          = ""
    @State private var dui               = ""
    @State private var password          = ""
    @State private var confirmPassword   = ""
    @State private var passwordVisible   = false
    @State private var confirmVisible    = false

    // Proyecto
    @State private var selectedProyecto: ProyectoResponseItem? = nil
    @State private var isSpinnerExpanded = false

    // Foto
    @State private var capturedImage: UIImage? = nil
    @State private var showCamera        = false

    // UI state
    @State private var isLoading         = false
    @State private var isVisible         = false
    @State private var showSuccess       = false
    @State private var alertMessage      = ""
    @State private var showAlert         = false

    private var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    private var isFormValid: Bool {
        !nombre.isBlank && !apellido.isBlank && !email.isBlank &&
        !telefono.isBlank && !dui.isBlank && !password.isBlank &&
        !confirmPassword.isBlank && selectedProyecto != nil && capturedImage != nil
    }

    var body: some View {
        ZStack {
            // Fondo
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
                    VStack(spacing: 12) {
                        Image("logo_alpha_02")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        Text("Crear Cuenta")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Completa tus datos para registrarte\nen Alpha Inmobiliaria")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -40)
                    .animation(.easeOut(duration: 0.6), value: isVisible)

                    Spacer().frame(height: 32)

                    // Card del formulario
                    VStack(spacing: 16) {
                        // Nombre
                        DarkTextField(
                            text: $nombre,
                            placeholder: "Nombre",
                            icon: "person",
                            keyboardType: .default,
                            textContentType: .givenName
                        )

                        // Apellido
                        DarkTextField(
                            text: $apellido,
                            placeholder: "Apellido",
                            icon: "person",
                            keyboardType: .default,
                            textContentType: .familyName
                        )

                        // Email
                        DarkTextField(
                            text: $email,
                            placeholder: "Correo electrónico",
                            icon: "envelope",
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )

                        // Teléfono
                        DarkTextField(
                            text: $telefono,
                            placeholder: "Teléfono",
                            icon: "phone",
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        )

                        // DUI
                        DarkTextField(
                            text: $dui,
                            placeholder: "ID (DUI o pasaporte)",
                            icon: "creditcard",
                            keyboardType: .default
                        )

                        // Contraseña
                        DarkSecureField(
                            text: $password,
                            placeholder: "Contraseña",
                            isVisible: $passwordVisible,
                            isError: false
                        )

                        // Repetir contraseña
                        DarkSecureField(
                            text: $confirmPassword,
                            placeholder: "Repetir contraseña",
                            isVisible: $confirmVisible,
                            isError: passwordMismatch,
                            errorMessage: passwordMismatch ? "Las contraseñas no coinciden" : nil
                        )

                        // Proyecto picker
                        ProyectoPickerView(
                            proyectos: proyectoVM.proyectos,
                            isLoading: proyectoVM.isLoading,
                            selected: $selectedProyecto,
                            isExpanded: $isSpinnerExpanded
                        )

                        // Sección foto
                        FotoIdentidadSection(
                            capturedImage: capturedImage,
                            onTakePhoto: { showCamera = true }
                        )

                        // Botón crear cuenta
                        Button(action: handleRegister) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text("Crear cuenta")
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
            proyectoVM.getProyectos()
        }
        // Cámara frontal
        .fullScreenCover(isPresented: $showCamera) {
            FrontCameraView { image in
                capturedImage = image
                showCamera = false
            } onCancel: {
                showCamera = false
            }
        }
        // Alert errores
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        // Diálogo éxito
        .alert("¡Cuenta creada!", isPresented: $showSuccess) {
            Button("Cerrar") { onBackToLogin?() }
        } message: {
            Text("Gracias por crear tu cuenta. Te notificaremos por correo electrónico una vez que la cuenta esté activa. Este proceso puede demorar hasta 24 horas.")
        }
    }

    // MARK: - Validación y registro

    private func handleRegister() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        guard !nombre.isBlank, !apellido.isBlank, !email.isBlank,
              !telefono.isBlank, !dui.isBlank, !password.isBlank else {
            showAlert(message: "Por favor completa todos los campos")
            return
        }
        guard password.count >= 8 else {
            showAlert(message: "La contraseña debe tener al menos 8 caracteres")
            return
        }
        guard password == confirmPassword else {
            showAlert(message: "Las contraseñas no coinciden")
            return
        }
        guard !dui.contains("-") else {
            showAlert(message: "El DUI no puede contener guiones")
            return
        }
        guard let proyecto = selectedProyecto else {
            showAlert(message: "Por favor selecciona un proyecto")
            return
        }
        guard isValidEmail(email) else {
            showAlert(message: "Por favor ingresa un correo válido")
            return
        }
        guard let foto = capturedImage else {
            showAlert(message: "Por favor toma una foto de tu rostro")
            return
        }

        isLoading = true

        // Paso 1 — Registro SAP
        let newClientRequest = NewClientSAPRequest(
            CardName: nombre,
            CardType: "C",
            FederalTaxID: dui,
            Series: 72,
            cellular: telefono,
            phone1: ""
        )

        Task {
            do {
                _ = try await registerVM.registerSAPClient(
                    db: proyecto.sap_id_proyecto ?? "",
                    body: newClientRequest
                )

                // Paso 2 — Registro de usuario con foto
                let fotoData = foto.jpegData(compressionQuality: 0.8)

                userRegisterVM.register(
                    email: email,
                    password: password,
                    nombre: "\(nombre) \(apellido)".trimmingCharacters(in: .whitespaces),
                    documento: dui.trimmingCharacters(in: .whitespaces),
                    direccion: proyecto.direccion ?? "",
                    telefono: telefono,
                    foto: fotoData
                )

                isLoading = false
                showSuccess = true
            } catch {
                isLoading = false
                showAlert(message: error.localizedDescription)
            }
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}

// MARK: - Sub-componentes

struct DarkTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 20)
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(Color(hex: 0x9CA3AF))
                }
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(keyboardType == .default ? .words : .none)
                .autocorrectionDisabled()
        }
        .padding(14)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: 0x3F3F3F), lineWidth: 1)
        )
    }
}

struct DarkSecureField: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isVisible: Bool
    var isError: Bool = false
    var errorMessage: String? = nil

    var borderColor: Color { isError ? Color(hex: 0xEF4444) : Color(hex: 0x3F3F3F) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundColor(.white)
                    .frame(width: 20)

                Group {
                    if isVisible {
                        TextField("", text: $text)
                            .placeholder(when: text.isEmpty) {
                                Text(placeholder).foregroundColor(Color(hex: 0x9CA3AF))
                            }
                    } else {
                        SecureField("", text: $text)
                            .placeholder(when: text.isEmpty) {
                                Text(placeholder).foregroundColor(Color(hex: 0x9CA3AF))
                            }
                    }
                }
                .foregroundColor(.white)

                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundColor(isError ? Color(hex: 0xEF4444) : Color(hex: 0x9CA3AF))
                }
            }
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let msg = errorMessage {
                Text(msg)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0xEF4444))
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct ProyectoPickerView: View {
    let proyectos: [ProyectoResponseItem]
    let isLoading: Bool
    @Binding var selected: ProyectoResponseItem?
    @Binding var isExpanded: Bool

    var body: some View {
        Menu {
            if proyectos.isEmpty {
                Text("No hay proyectos disponibles")
                    .foregroundColor(Color(hex: 0x9CA3AF))
            } else {
                ForEach(proyectos) { proyecto in
                    Button(proyecto.nombre) {
                        selected = proyecto
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "building.2")
                    .foregroundColor(.white)
                    .frame(width: 20)
                Text(selected?.nombre ?? (isLoading ? "Cargando proyectos..." : "Selecciona un proyecto"))
                    .foregroundColor(selected == nil ? Color(hex: 0x9CA3AF) : .white)
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: 0x9CA3AF)))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.up.chevron.down")
                        .foregroundColor(Color(hex: 0x9CA3AF))
                        .font(.caption)
                }
            }
            .padding(14)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: 0x3F3F3F), lineWidth: 1)
            )
        }
    }
}

struct FotoIdentidadSection: View {
    let capturedImage: UIImage?
    let onTakePhoto: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verificación de identidad")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Text("Necesitamos una foto de tu rostro para validar tu identidad.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .lineSpacing(4)

            // Preview si hay foto
            if let image = capturedImage {
                HStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: 0x10B981), lineWidth: 2))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("✓  Foto tomada")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: 0x10B981))
                        Text("Puedes volver a tomarla si lo deseas")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(hex: 0x1A3A2A))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Botón cámara
            Button(action: onTakePhoto) {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 16))
                    Text(capturedImage == nil ? "Tomarme una foto" : "Volver a tomar foto")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: 0x9CA3AF), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(Color(hex: 0x2A2A2A))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: capturedImage != nil)
    }
}

// MARK: - Helpers

extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

