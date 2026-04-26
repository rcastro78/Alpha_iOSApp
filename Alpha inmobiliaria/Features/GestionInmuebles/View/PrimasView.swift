//
//  PrimasView.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 6/4/26.
//
import SwiftUI
import PDFKit
import UIKit




private func limpiarColor(_ hex: String) -> Color {
    var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleaned.hasPrefix("#") { cleaned = String(cleaned.dropFirst()) }
    if cleaned.hasPrefix("0x") || cleaned.hasPrefix("0X") { cleaned = String(cleaned.dropFirst(2)) }
    guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return .gray }
    let r = Double((value >> 16) & 0xFF) / 255
    let g = Double((value >> 8)  & 0xFF) / 255
    let b = Double(value         & 0xFF) / 255
    return Color(red: r, green: g, blue: b)
}

private func formatMoney(_ value: Double) -> String {
    let fmt = NumberFormatter()
    fmt.numberStyle = .decimal
    fmt.minimumFractionDigits = 2
    fmt.maximumFractionDigits = 2
    fmt.groupingSeparator = ","
    return "$\(fmt.string(from: NSNumber(value: value)) ?? "0.00")"
}

// MARK: - Main View

struct PrimasView: View {

    @ObservedObject var inmuebleViewModel: InmuebleViewModel
    @ObservedObject var amortizacionViewModel: AmortizacionViewModel
    @AppStorage("clienteId") private var clienteId = ""
    @AppStorage("name")      private var userName   = ""
    @State private var selectedInmueble: Inmueble?
    @State private var primaSeleccionada: Amortizacion?
    @State private var mostrarMenuExportar = false
    @State private var mostrarRecibo = false

    var onBack: (() -> Void)?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                let inmueblesList: [Inmueble] = inmuebleViewModel.inmuebleResponse?.inmuebles ?? []
                
                // Property picker
                InmuebleDropDown(
                    inmuebles: inmueblesList,
                    selected: $selectedInmueble,
                    inmuebleVieModel: inmuebleViewModel,
                    amortizacionViewModel: amortizacionViewModel
                )
                .padding()
                .background(Color(.systemGroupedBackground))

                // Content
                if let prima = primaSeleccionada {
                    DetallePrimaView(
                        prima: prima,
                        inmueble: selectedInmueble,
                        totalPendiente: totalPendiente,
                        userName: userName,
                        onBack: { primaSeleccionada = nil }
                    )
                } else {
                    ListaPrimasView(
                        primas: amortizacionViewModel.amortizacionesResponse?.amortizaciones ?? [],
                        inmueble: selectedInmueble,
                        isLoading: inmuebleViewModel.isLoading,
                        onPrimaClick: { primaSeleccionada = $0 }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onBack?() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Gestión de Pagos")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            mostrarRecibo = true
                        } label: {
                            Label("Exportar a PDF", systemImage: "doc.fill")
                        }
                        Button {
                            // TODO: Excel export
                        } label: {
                            Label("Exportar a Excel", systemImage: "tablecells")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color(red: 0.12, green: 0.12, blue: 0.12), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            if inmuebleViewModel.inmuebleResponse == nil {
                    inmuebleViewModel.getInmueblesCliente(clienteId)
                }
        }
        .sheet(isPresented: $mostrarRecibo) {
            Text("Recibo PDF — pendiente de implementar")
                .padding()
        }
    }

    private var totalPendiente: Double {
        // Safely get amortizaciones from the view model's response to avoid dynamic member issues
        let source: [Amortizacion] = amortizacionViewModel.amortizacionesResponse?.amortizaciones ?? []
        var sum: Double = 0
        for item in source {
            if item.estadoPago == "Pendiente" {
                if let monto = Double(item.montoCuota) {
                    sum += monto
                }
            }
        }
        return sum
    }
}

// MARK: - Lista de Primas

struct ListaPrimasView: View {
    let primas: [Amortizacion]
    let inmueble: Inmueble?
    let isLoading: Bool
    let onPrimaClick: (Amortizacion) -> Void

    @State private var filtro: String? = nil

    private var totalPendiente: Double {
        primas.filter { $0.estadoPago == "Pendiente" }
              .compactMap { Double($0.montoCuota) }.reduce(0, +)
    }
    private var pagadas: Int { primas.filter { $0.estadoPago == "Pagado" }.count }
    private var totalCuotas: Int { primas.filter { $0.tipoPago.lowercased() == "cuota" }.count }

    private var primasFiltradas: [Amortizacion] {
        guard let f = filtro else { return primas }
        return primas.filter { $0.estadoPago == f }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Summary header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cuotas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(primas.count)")
                        .font(.title2).bold()
                        .foregroundColor(.accentColor)
                    Text("\(pagadas) pagadas")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Saldo Pendiente")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatMoney(totalPendiente))
                        .font(.title2).bold()
                        .foregroundColor(Color.orange)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(label: "Todos", selected: filtro == nil) { filtro = nil }
                    FilterChip(label: "Pendiente", selected: filtro == "Pendiente") { filtro = "Pendiente" }
                    FilterChip(label: "Pagado",    selected: filtro == "Pagado")    { filtro = "Pagado" }
                    FilterChip(label: "En Revisión", selected: filtro == "En Revisión") { filtro = "En Revisión" }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            if isLoading {
                Spacer()
                ProgressView("Cargando pagos...")
                Spacer()
            } else if primasFiltradas.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(primas.isEmpty ? "No hay primas disponibles" : "Sin resultados para el filtro")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(primasFiltradas, id: \.numeroPago) { prima in
                            TarjetaPrimaView(
                                prima: prima,
                                inmueble: inmueble,
                                totalCuotas: totalCuotas,
                                onTap: { onPrimaClick(prima) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Tarjeta de Prima

struct TarjetaPrimaView: View {
    let prima: Amortizacion
    let inmueble: Inmueble?
    let totalCuotas: Int
    let onTap: () -> Void

    private var estadoColor: Color {
        switch prima.estadoPago {
        case "Pagado":     return Color(hex: 0xFFD700)
        case "Pendiente":  return .white
        case "En Revisión": return Color(hex: 0xFF9500)
        default:           return .gray
        }
    }

    private var tipoPagoColor: Color {
        switch prima.tipoPago {
        case "PreReserva":   return Color(hex: 0xFFD700)
        case "Firma de PCV": return Color(hex: 0x0288D1)
        case "Cuota":        return .white
        default:             return .gray
        }
    }

    private var estadoTexto: String {
        switch prima.estadoPago {
        case "Pagado":      return "Pagado"
        case "Pendiente":   return "Pendiente"
        case "En Revisión": return "En Revisión"
        default:            return prima.estadoPago
        }
    }

    private var tipoPagoTexto: String {
        switch prima.tipoPago {
        case "PreReserva":   return "PreReserva"
        case "Firma de PCV": return "Firma de PCV"
        case "Cuota":
            let n = Int(prima.numeroPago)! - 2
            return "Cuota \(n)/\(totalCuotas)"
        default: return prima.tipoPago
        }
    }

    private var recCode: String {
        let year = prima.fechaEstimada.prefix(4)
        let num  = String(format: "%04d", prima.numeroPago)
        return "REC-\(year)-\(num)"
    }

    private var montoMostrado: Double {
        prima.estadoPago == "Pagado"
            ? Double(prima.montoReal ?? "0") ?? 0
            : Double(prima.montoCuota) ?? 0
    }

    private var headerGradient: LinearGradient {
        if prima.estadoPago == "Pendiente", let inm = inmueble {
            return LinearGradient(
                colors: [
                    limpiarColor(inm.color_oscuro),
                    limpiarColor(inm.color_medio),
                    limpiarColor(inm.color_brillante)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(hex: 0x0D1B2A), Color(hex: 0x1B2838), Color(hex: 0x1F3A5F)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .leading) {
                    headerGradient
                    // Decorative circles
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 130, height: 130)
                        .offset(x: 220, y: -30)
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 70, height: 70)
                        .offset(x: 280, y: 30)

                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(recCode)
                                .font(.headline).bold()
                                .foregroundColor(.white)
                            BadgePill(label: tipoPagoTexto, color: tipoPagoColor)
                        }
                        Spacer()
                        BadgePill(label: estadoTexto, color: estadoColor)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
                .frame(height: 90)
                .clipped()

                // Body
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        InfoChipPrimasView(
                            icon: "calendar",
                            label: "Fecha estimada",
                            value: formatearFecha(prima.fechaEstimada)
                        )
                        if let fr = prima.fechaReal {
                            InfoChipPrimasView(
                                icon: "checkmark.circle.fill",
                                label: "Fecha pago",
                                value: formatearFecha(fr),
                                iconColor: .green
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        MontoCardPrimasView(
                            label: "Balance estimado",
                            value: formatMoney(Double(prima.balanceEstimado) ?? 0),
                            valueColor: Color(hex: 0x555555)
                        )
                        MontoCardPrimasView(
                            label: prima.estadoPago == "Pagado" ? "Monto pagado" : "Cuota",
                            value: formatMoney(montoMostrado),
                            valueColor: prima.estadoPago == "Pagado"
                                ? .green
                                : prima.estadoPago == "Pendiente"
                                    ? Color(hex: 0x1F3A5F)
                                    : .orange
                        )
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
            }
        }
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}

// MARK: - Detalle de Prima

struct DetallePrimaView: View {
    let prima: Amortizacion
    let inmueble: Inmueble?
    let totalPendiente: Double
    let userName: String
    let onBack: () -> Void

    @State private var mostrarRecibo = false
    @AppStorage("totalPendiente") private var savedTotalPendiente = ""

    private var estadoColor: Color {
        switch prima.estadoPago {
        case "Pagado":      return .green
        case "Pendiente":   return .orange
        case "En Revisión": return Color(hex: 0xFF9500)
        default:            return .gray
        }
    }

    private var tipoPagoColor: Color {
        switch prima.tipoPago {
        case "PreReserva":   return Color(hex: 0xFFD700)
        case "Firma de PCV": return Color(hex: 0x0288D1)
        case "Cuota":        return .white
        default:             return .gray
        }
    }

    private var estadoTexto: String {
        switch prima.estadoPago {
        case "Pagado":      return "Pagado"
        case "Pendiente":   return "Pendiente"
        case "En Revisión": return "En Revisión"
        default:            return prima.estadoPago
        }
    }

    private var tipoPagoTexto: String {
        switch prima.tipoPago {
        case "PreReserva":   return "PreReserva"
        case "Firma de PCV": return "Firma de PCV"
        case "Cuota":        return "Cuota"
        default:             return prima.tipoPago
        }
    }

    private var recCode: String {
        let year = prima.fechaEstimada.prefix(4)
        let num  = String(format: "%04d", prima.numeroPago)
        return "REC-\(year)-\(num)"
    }

    private var headerGradient: LinearGradient {
        if prima.estadoPago == "Pendiente", let inm = inmueble {
            return LinearGradient(
                colors: [
                    limpiarColor(inm.color_oscuro),
                    limpiarColor(inm.color_medio),
                    limpiarColor(inm.color_brillante)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color(hex: 0x0D1B2A), Color(hex: 0x1B2838), Color(hex: 0x1F3A5F)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero header
                ZStack(alignment: .topLeading) {
                    headerGradient
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 220, height: 220)
                        .offset(x: 220, y: -60)
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 120, height: 120)
                        .offset(x: 290, y: 80)

                    VStack(alignment: .leading, spacing: 0) {
                        // Nav row
                        HStack {
                            Button(action: onBack) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                            Spacer()
                            Text("Detalle de Pago")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Menu {
                                Button {
                                    mostrarRecibo = true
                                } label: {
                                    Label("Descargar PDF", systemImage: "doc.richtext")
                                }
                            } label: {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                        // Hero content
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recCode)
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            HStack(spacing: 8) {
                                BadgePill(label: tipoPagoTexto, color: tipoPagoColor)
                                BadgePill(label: estadoTexto,   color: estadoColor)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                }
                .frame(height: 200)
                .clipped()

                // Scrollable content
                VStack(spacing: 14) {
                    // Información de pago
                    SeccionDetalleView(titulo: "Información de pago") {
                        DetalleItemView(label: "Tipo de pago",     value: tipoPagoTexto,                          icon: "tag")
                        DetalleItemView(label: "Cuota",            value: formatMoney(Double(prima.montoCuota) ?? 0), icon: "creditcard")
                        DetalleItemView(label: "Balance estimado", value: formatMoney(Double(prima.balanceEstimado) ?? 0), icon: "chart.bar", isLast: true)
                    }

                    // Fechas
                    SeccionDetalleView(titulo: "Fechas") {
                        DetalleItemView(
                            label: "Fecha estimada",
                            value: formatearFecha(prima.fechaEstimada),
                            icon: "calendar",
                            isLast: prima.fechaReal == nil
                        )
                        if let fr = prima.fechaReal {
                            DetalleItemView(
                                label: "Fecha real de pago",
                                value: formatearFecha(fr),
                                icon: "checkmark.circle",
                                valueColor: .green,
                                isLast: true
                            )
                        }
                    }

                    // Detalles del pago (Pagado / En Revisión)
                    if prima.estadoPago == "Pagado" || prima.estadoPago == "En Revisión" {
                        SeccionDetalleView(titulo: "Detalles del pago") {
                            if let mr = prima.montoReal {
                                DetalleItemView(label: "Monto pagado",    value: formatMoney(Double(mr) ?? 0),            icon: "dollarsign.circle", valueColor: .green)
                            }
                            DetalleItemView(label: "Monto acumulado",     value: formatMoney(Double(prima.montoPagadoAcumulado) ?? 0), icon: "banknote")
                            DetalleItemView(label: "Exceso",              value: formatMoney(Double(prima.montoExceso) ?? 0),            icon: "plus.circle")
                            DetalleItemView(label: "Saldo pendiente",     value: formatMoney(Double(prima.saldoPendiente) ?? 0),         icon: "hourglass", isLast: true)
                        }
                    }

                    // Botón registrar pago
                    if prima.estadoPago == "Pendiente" {
                        NavigationLink(destination: RegistrarPagoView(prima: prima, totalPendiente: totalPendiente)) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Registrar Pago")
                                    .font(.headline).bold()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .green.opacity(0.3), radius: 6, y: 3)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            UserDefaults.standard.set(
                                String(format: "%.2f", totalPendiente),
                                forKey: "totalPendiente"
                            )
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $mostrarRecibo) {
            // TODO: Implement receipt sheet (ReciboView)
            Text("Recibo — pendiente de implementar")
                .padding()
        }
    }
}

// MARK: - Placeholder for RegistrarPagoView

struct RegistrarPagoView: View {
    let prima: Amortizacion
    let totalPendiente: Double
    var body: some View {
        Text("Registrar Pago — pendiente de implementar")
            .navigationTitle("Registrar Pago")
    }
}

// MARK: - InmuebleDropDown

struct InmuebleDropDown: View {
    let inmuebles: [Inmueble]
    @Binding var selected: Inmueble?
    let inmuebleVieModel: InmuebleViewModel
    let amortizacionViewModel: AmortizacionViewModel

    private var selectedText: String {
        guard let s = selected else { return "Seleccione un inmueble" }
        return "\(s.nombre_proyecto) - #\(s.numero_inmueble)"
    }

    var body: some View {
        Menu {
            ForEach(inmuebles) { inmueble in
                Button {
                    Task { await select(inmueble) }
                } label: {
                    VStack(alignment: .leading) {
                        Text(inmueble.nombre_proyecto).bold()
                        Text("# \(inmueble.numero_inmueble)").font(.caption)
                    }
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Inmueble")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(selectedText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .onAppear {
            if selected == nil, let first = inmuebles.first {
                Task { await select(first) }
            }
        }
    }

    
    private func select(_ inmueble: Inmueble) {
        selected = inmueble
        saveToDefaults(inmueble)
        Task {
            do {
                let response = try await amortizacionViewModel.getAmortizaciones(ventaId: inmueble.venta_id)
                 amortizacionViewModel.amortizacionesResponse = response
            } catch {
                await MainActor.run {
                    amortizacionViewModel.errorMessage = error.localizedDescription
                    amortizacionViewModel.isLoading = false
                }
            }
        }
    }
    
    private func saveToDefaults(_ inm: Inmueble) {
        let ud = UserDefaults.standard
        ud.set(inm.inmueble_id,     forKey: "inmuebleId")
        ud.set(inm.venta_id,        forKey: "ventaId")
        ud.set(inm.numero_inmueble, forKey: "numeroInmueble")
        ud.set(inm.nombre_proyecto, forKey: "nombreProyecto")
        ud.set(inm.proyecto_id,     forKey: "proyectoId")
        ud.set(inm.public_key,      forKey: "publicKey")
        ud.set(inm.private_key,     forKey: "privateKey")
        ud.set(inm.id_sap_cliente,  forKey: "cardCode")
        ud.set(inm.xdb,             forKey: "xdb")
    }
}

// MARK: - Reusable sub-components

struct BadgePill: View {
    let label: String
    let color: Color
    var body: some View {
        Text(label)
            .font(.caption2).bold()
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.5), lineWidth: 1))
    }
}

struct FilterChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption).bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                .foregroundColor(selected ? .white : .secondary)
                .clipShape(Capsule())
        }
    }
}

struct InfoChipPrimasView: View {
    let icon: String
    let label: String
    let value: String
    var iconColor: Color = Color(hex: 0x1F3A5F)

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption).bold()
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct MontoCardPrimasView: View {
    let label: String
    let value: String
    let valueColor: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline).bold()
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SeccionDetalleView<Content: View>: View {
    let titulo: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo)
                .font(.caption).bold()
                .foregroundColor(.accentColor)
                .tracking(0.5)
            content
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct DetalleItemView: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = Color(hex: 0x1A1A1A)
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: 0xF0F4FF))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x1F3A5F))
                }
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline).bold()
                    .foregroundColor(valueColor)
            }
            .padding(.vertical, 8)

            if !isLast {
                Divider()
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt64) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double(hex         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

