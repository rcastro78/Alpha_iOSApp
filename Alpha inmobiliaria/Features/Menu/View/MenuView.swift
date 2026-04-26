//
//  MenuView.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//

import SwiftUI

enum MenuDestination: Hashable {
    case gestionPropiedades
    case cuotas
    case historial
    case estadoCuenta
}

struct MenuView: View {
    var onLogout: (() -> Void)? = nil

    private let userName  = UserDefaults.standard.string(forKey: "profileName") ?? "Usuario"
    private let clienteId = UserDefaults.standard.string(forKey: "profileId")   ?? ""

    @StateObject private var inmuebleViewModel = InmuebleViewModel(
        inmuebleRepository: InmuebleRepository()
    )
    
    @StateObject private var amortizacionViewModel = AmortizacionViewModel(
        amortizacionRepository: AmortizacionRepository()
    )

    @State private var navPath = NavigationPath()
    @State private var isVisible = false

    var body: some View {
        // NavigationStack propio — no depende del padre
        NavigationStack(path: $navPath) {
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

                        headerView
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : -40)
                            .animation(.easeOut(duration: 0.6), value: isVisible)

                        Spacer().frame(height: 24)

                        VStack(alignment: .leading, spacing: 0) {

                            // ── Mis Propiedades ───────────────────────────
                            sectionTitle("Mis Propiedades")
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.1), value: isVisible)

                            Spacer().frame(height: 12)

                            MenuCardRow(title: "Gestión de propiedades",
                                        description: "Ver mis propiedades",
                                        icon: "🏢")
                                .onTapGesture {
                                    navPath.append(MenuDestination.gestionPropiedades)
                                }
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

                            Spacer().frame(height: 24)

                            // ── Finanzas ──────────────────────────────────
                            sectionTitle("Finanzas")
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                            Spacer().frame(height: 12)

                            MenuCardRow(title: "Cuotas", description: "", icon: "📄")
                                .onTapGesture {
                                    navPath.append(MenuDestination.cuotas)
                                }
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.25), value: isVisible)

                            Spacer().frame(height: 12)

                            MenuCardRow(title: "Historial", description: "", icon: "📊")
                                .onTapGesture {
                                    navPath.append(MenuDestination.historial)
                                }
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)

                            Spacer().frame(height: 12)

                            MenuCardRow(title: "Estado de cuenta", description: "", icon: "💰")
                                .onTapGesture {
                                    navPath.append(MenuDestination.estadoCuenta)
                                }
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 40)
                                .animation(.easeOut(duration: 0.6).delay(0.35), value: isVisible)

                            Spacer().frame(height: 32)

                            // ── Cerrar sesión ─────────────────────────────
                            Button(action: { onLogout?() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18))
                                    Text("Cerrar Sesión")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .opacity(isVisible ? 1 : 0)
                            .animation(.easeOut(duration: 0.6).delay(0.45), value: isVisible)

                            Spacer().frame(height: 24)
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationBarHidden(true)
            // Registro de destinos — swiftUI hace el push automáticamente
            .navigationDestination(for: MenuDestination.self) { dest in
                switch dest {
                case .gestionPropiedades:
                    GestionInmueblesView(
                        viewModel: inmuebleViewModel,
                        clienteId: clienteId
                    )
                    .navigationBarHidden(true)

                case .cuotas:
                    PrimasView(inmuebleViewModel: inmuebleViewModel,
                               amortizacionViewModel: amortizacionViewModel,
                               onBack: { navPath.removeLast() })
                            .navigationBarHidden(true)

                case .historial:
                    PlaceholderView(title: "Historial")
                        .navigationBarHidden(true)

                case .estadoCuenta:
                    PlaceholderView(title: "Estado de cuenta")
                        .navigationBarHidden(true)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isVisible = true
                }
            }
        }
    }

    // ── Header ────────────────────────────────────────────────────────────────
    private var headerView: some View {
        VStack(spacing: 12) {
            Image("logo_alpha_02")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("Bienvenido")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))

            Text(userName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .shadow(radius: 8)
    }

    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
    }
}

// ── MenuCardRow ───────────────────────────────────────────────────────────────
struct MenuCardRow: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 56, height: 56)
                Text(icon)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                if !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(20)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        .contentShape(Rectangle())
    }
}

// ── PlaceholderView ───────────────────────────────────────────────────────────
struct PlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.06).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("🚧").font(.system(size: 64))
                Text(title)
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Próximamente")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}
