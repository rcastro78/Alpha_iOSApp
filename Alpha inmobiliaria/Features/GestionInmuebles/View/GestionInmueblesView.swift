//
//  GestionInmueblesView.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 31/3/26.
//
import SwiftUI

// MARK: - Color Helper
extension Color {
    init(hex: String) {
        var cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        // Soporta formato Android: "0xFF0A4D43"
        if cleaned.lowercased().hasPrefix("0xff") {
            cleaned = String(cleaned.dropFirst(4))  // quita "0xFF" → "0A4D43"
        }
        // Soporta ARGB de 8 chars sin prefijo: "FF0A4D43"
        if cleaned.count == 8 {
            cleaned = String(cleaned.dropFirst(2))
        }

        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8)  & 0xFF) / 255.0,
            blue:  Double( rgb        & 0xFF) / 255.0
        )
    }
}

// MARK: - Number Formatting Helper
private extension Double {
    func toCurrency(decimals: Int = 2) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = decimals
        fmt.maximumFractionDigits = decimals
        fmt.groupingSeparator = ","
        return "$\(fmt.string(from: NSNumber(value: self)) ?? "0.00")"
    }
}

// MARK: - Estado Color Helper
private func estadoColor(for estado: String) -> Color {
    let upper = estado.uppercased()
    if upper.contains("PROCESO")     { return Color(hex: "FFA726") }
    if upper.contains("COMPLETADO")  { return Color(hex: "66BB6A") }
    if upper == "HABITADO"           { return Color(hex: "42A5F5") }
    return Color(hex: "90A4AE")
}

// ============================================================
// MARK: - GestionInmueblesView  (Root)
// ============================================================
struct GestionInmueblesView: View {
    @ObservedObject var viewModel: InmuebleViewModel
    let clienteId: String
    @State private var goToMovimientos: Inmueble? = nil
    
    /// Called when the user taps a property card (for cross-activity navigation)
    var onInmuebleClick: ((Inmueble) -> Void)? = nil
    /// Called when the back button is tapped at root level
    @Environment(\.dismiss) private var dismiss

    @State private var inmuebleSeleccionado: Inmueble? = nil

    private let navBG = Color(hex: "1A1A1A")

    var body: some View {
        VStack(spacing: 0) {
            // ── Custom TopAppBar ─────────────────────────────
            HStack {
                Button {
                    if inmuebleSeleccionado != nil {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            inmuebleSeleccionado = nil
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(inmuebleSeleccionado == nil ? "Mis Propiedades" : "Detalle")
                    .font(.headline).fontWeight(.bold)
                    .foregroundColor(.white)
                    .animation(.none, value: inmuebleSeleccionado == nil)

                Spacer()

                // Logo placeholder — swap "logo_alpha_02" for your asset name
                Image(systemName: "building.2")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(navBG)

            // ── Content ──────────────────────────────────────
            if let inmueble = inmuebleSeleccionado {
                DetalleInmuebleView(inmueble: inmueble)
                    .transition(.move(edge: .trailing))
            } else {
                ListaInmueblesView(
                    viewModel: viewModel,
                    clienteId: clienteId,
                    onInmuebleClick: { inmueble in
                        withAnimation { goToMovimientos = inmueble }
                    },
                    onCreateComplaint: { _ in
                        // Navigate to CrearQuejaView
                    },
                    onCreatePayment: { _ in
                        // Navigate to RegistrarAnticipoView
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .leading))
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .fullScreenCover(item: $goToMovimientos) { inmueble in
            MovimientosScreen(
                movimientoViewModel: viewModel,
                ventaId: inmueble.venta_id,
                onBack: { goToMovimientos = nil }
            )
        }
        
        
    }
}

// ============================================================
// MARK: - ListaInmueblesView
// ============================================================
struct ListaInmueblesView: View {
    @ObservedObject var viewModel: InmuebleViewModel
    let clienteId: String
    var onInmuebleClick:    ((Inmueble) -> Void)? = nil
    var onCreateComplaint:  ((Inmueble) -> Void)? = nil
    var onCreatePayment:    ((Inmueble) -> Void)? = nil

    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color(hex: "1A1A1A"))
                    .scaleEffect(1.4)

            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding(32)

            } else if let inmuebles = viewModel.inmuebleResponse?.inmuebles, !inmuebles.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(inmuebles, id: \.inmueble_id) { inmueble in
                            TarjetaInmuebleView(
                                inmueble: inmueble,
                                onClick: { onInmuebleClick?(inmueble) },
                                onCreateComplaint: onCreateComplaint,
                                onCreatePayment: onCreatePayment
                            )
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                VStack(spacing: 16) {
                    Image(systemName: "house")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "CCCCCC"))
                    Text("No tienes propiedades")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(32)
            }
        }
        .task {
            try? await viewModel.obtenerInmueble(clienteId: clienteId)
        }
    }
}

// ============================================================
// MARK: - TarjetaInmuebleView
// ============================================================
struct TarjetaInmuebleView: View {
    let inmueble: Inmueble
    var onClick: (() -> Void)? = nil
    var onCreateComplaint: ((Inmueble) -> Void)? = nil
    var onCreatePayment:   ((Inmueble) -> Void)? = nil

    @State private var animatedProgress: Double = 0

    private var progreso: Double {
        guard Double(inmueble.monto_total)! > 0.0 else { return 0 }
        return min(Double(inmueble.monto_pagado)! / Double(inmueble.monto_total)!, 1.0)
    }

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: inmueble.color_oscuro),
                Color(hex: inmueble.color_medio),
                Color(hex: inmueble.color_brillante)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var eColor: Color { estadoColor(for: inmueble.estado) }

    var body: some View {
        Button(action: { onClick?() }) {
            VStack(spacing: 0) {

                // ── Header ───────────────────────────────────
                ZStack(alignment: .topTrailing) {
                    // Gradient background
                    headerGradient
                        .frame(height: 140)

                    // Decorative circles
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 180)
                        .offset(x: 60, y: -40)

                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 100)
                        .offset(x: 80, y: 30)

                    // Content
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            // Project name + type
                            VStack(alignment: .leading, spacing: 4) {
                                Text(inmueble.nombre_proyecto)
                                    .font(.title2).fontWeight(.black)
                                    .foregroundColor(.white)
                                    .kerning(-0.5)

                                HStack(spacing: 4) {
                                    Image(systemName: "mappin")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(inmueble.tipo_proyecto)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .kerning(0.5)
                                }
                            }
                            Spacer()

                            // Estado badge
                            Text(inmueble.estado)
                                .font(.caption).fontWeight(.bold)
                                .kerning(0.5)
                                .foregroundColor(eColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(eColor.opacity(0.18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(eColor.opacity(0.5), lineWidth: 1)
                                )
                                .clipShape(Capsule())
                        }

                        Spacer()

                        // Unit number + address
                        HStack(spacing: 8) {
                            Text("# \(inmueble.numero_inmueble)")
                                .font(.subheadline).fontWeight(.bold)
                                .kerning(1)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(inmueble.direccion)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.45))
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(height: 140)
                }

                // ── Body ─────────────────────────────────────
                VStack(spacing: 20) {

                    // Progress bar
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progreso de pago")
                                .font(.caption).kerning(0.5)
                                .foregroundColor(Color(hex: "888888"))
                            Spacer()
                            Text("\(Int(progreso * 100))%")
                                .font(.caption).fontWeight(.black)
                                .foregroundColor(Color(hex: "1F3A5F"))
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color(hex: "F0F0F0"))
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "1F3A5F"), Color(hex: "4CAF50")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * animatedProgress)
                            }
                        }
                        .frame(height: 7)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.9)) {
                                animatedProgress = progreso
                            }
                        }
                    }

                    // Amount cards
                    VStack(spacing: 8) {
                        MontoCardView(
                            label: "Monto de cuotas",
                            value: Double(inmueble.monto_total)!.toCurrency(),
                            valueColor: Color(hex: "1A1A1A")
                        )
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 8) {
                            MontoCardView(
                                label: "Pagadas",
                                value: inmueble.pagadas,
                                valueColor: Color(hex: "2E7D32"),
                                textAlignment: .leading
                            )
                            MontoCardView(
                                label: "Saldo restante",
                                value: (Double(inmueble.monto_total)! - Double(inmueble.monto_pagado)!).toCurrency(),
                                valueColor: Color(hex: "E53935")
                            )
                        }
                    }

                    // Cuota + plazo chips
                    HStack(spacing: 10) {
                        InfoChipView(
                            icon: "creditcard.fill",
                            label: "Cuota mensual",
                            value: Double(inmueble.monto_cuota)!.toCurrency(decimals: 0)
                        )
                        InfoChipView(
                            icon: "calendar",
                            label: "Plazo",
                            value: "\(inmueble.plazo_meses) meses"
                        )
                    }

                    // Complaint button (HABITADO only)
                    if inmueble.estado.uppercased() == "HABITADO", let onCreateComplaint {
                        Button {
                            onCreateComplaint(inmueble)
                        } label: {
                            HStack(spacing: 8) {
                                Text("📝").font(.system(size: 18))
                                Text("Crear queja")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .kerning(0.3)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "FA5A0F"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(hex: "FA5A0F").opacity(0.3), radius: 6, y: 3)
                        }
                    }
                }
                .padding(20)
            }
        }
        .buttonStyle(.plain)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// ============================================================
// MARK: - DetalleInmuebleView
// ============================================================
struct DetalleInmuebleView: View {
    let inmueble: Inmueble

    private var progreso: Double {
        guard Double(inmueble.monto_total)! > 0.0 else { return 0 }
        return min(Double(inmueble.monto_pagado)! / Double(inmueble.monto_total)!, 1.0)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                // ── Header Card ──────────────────────────────
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [Color(hex: "1A1A1A"), Color(hex: "2D2D2D")],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: 180)

                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(inmueble.nombre_proyecto)
                                        .font(.title).fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Inmueble #\(inmueble.numero_inmueble)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Text(inmueble.estado)
                                    .font(.subheadline).fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(estadoColor(for: inmueble.estado))
                                    .clipShape(Capsule())
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.white)
                                Text(inmueble.direccion)
                                    .font(.body).foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(24)
                        .frame(height: 180)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                // ── Resumen Financiero ───────────────────────
                cardContainer {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Resumen financiero")
                                .font(.title3).fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "4CAF50"))
                        }

                        VStack(spacing: 8) {
                            ProgressView(value: progreso)
                                .progressViewStyle(.linear)
                                .tint(Color(hex: "4CAF50"))
                                .scaleEffect(x: 1, y: 1.8)

                            Text("\(Int(progreso * 100))% completado")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "4CAF50"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Divider()

                        VStack(spacing: 12) {
                            DetalleFinancieroView(label: "Monto total",
                                                 value: Double(inmueble.monto_total)!.toCurrency(),
                                                 color: Color(hex: "1A1A1A"))
                            DetalleFinancieroView(label: "Monto pagado",
                                                 value: Double(inmueble.monto_pagado)!.toCurrency(),
                                                 color: Color(hex: "4CAF50"))
                            DetalleFinancieroView(label: "Monto pendiente",
                                                 value: Double(inmueble.monto_pendiente)!.toCurrency(),
                                                 color: Color(hex: "E53935"))
                            DetalleFinancieroView(label: "Prima inicial",
                                                 value: Double(inmueble.monto_prima)!.toCurrency(),
                                                 color: Color(hex: "666666"))
                        }
                    }
                }

                // ── Plan de Pagos ────────────────────────────
                cardContainer {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Plan de Pagos")
                            .font(.title3).fontWeight(.bold)

                        HStack(spacing: 12) {
                            PlanPagoItemView(
                                icon: "calendar",
                                label: "Plazo",
                                value: "\(inmueble.plazo_meses) meses"
                            )
                            PlanPagoItemView(
                                icon: "creditcard",
                                label: "Cuota mensual",
                                value: Double(inmueble.monto_cuota)!.toCurrency(decimals: 0)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ── Información del Proyecto ─────────────────
                cardContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Información del Proyecto")
                            .font(.title3).fontWeight(.bold)

                        InfoProyectoItemView(label: "Tipo de proyecto", value: inmueble.tipo_proyecto)
                        InfoProyectoItemView(label: "Ubicación", value: inmueble.ubicacion)
                        InfoProyectoItemView(label: "ID Inmueble", value: inmueble.inmueble_id)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
        }
        .background(Color(hex: "F8F9FA"))
    }

    @ViewBuilder
    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.07), radius: 8, y: 4)
    }
}

// ============================================================
// MARK: - Supporting Components
// ============================================================

struct MontoCardView: View {
    let label: String
    let value: String
    let valueColor: Color
    var textAlignment: Alignment = .leading

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color(hex: "999999"))
                .kerning(0.3)
                .lineLimit(2)
            Text(value)
                .font(.caption).fontWeight(.black)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: textAlignment)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color(hex: "F8F9FA"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoChipView: View {
    let icon: String
    let label: String
    let value: String
    var iconTint: Color = Color(hex: "1F3A5F")

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconTint)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(hex: "888888"))
                Text(value)
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(Color(hex: "1F3A5F"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "F0F4FF"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct DetalleFinancieroView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(Color(hex: "666666"))
            Spacer()
            Text(value)
                .font(.subheadline).fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct PlanPagoItemView: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "1A1A1A"))
            Text(value)
                .font(.subheadline).fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))
            Text(label)
                .font(.caption)
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(hex: "F5F5F5"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoProyectoItemView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color(hex: "666666"))
            Text(value)
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(Color(hex: "1A1A1A"))
        }
    }
}

