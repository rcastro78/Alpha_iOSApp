//
//  MovimientosScreen.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 1/4/26.
//


import SwiftUI

// MARK: - Helpers

func formatearFecha(_ fecha: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: fecha) {
        let out = DateFormatter()
        out.dateFormat = "dd/MM/yy"
        return out.string(from: date)
    }
    return String(fecha.prefix(10))
}

func formatearFechaCompleta(_ fecha: String) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: fecha) {
        let out = DateFormatter()
        out.dateFormat = "dd 'de' MMMM 'de' yyyy, HH:mm"
        out.locale = Locale(identifier: "es_ES")
        return out.string(from: date)
    }
    return fecha
}

// MARK: - MovimientosScreen

struct MovimientosScreen: View {
    @ObservedObject var movimientoViewModel: InmuebleViewModel

    let ventaId: String
    var onBack: () -> Void = {}

    @State private var movimientoSeleccionado: Movimiento? = nil

    var body: some View {
        NavigationStack {
            Group {
                if movimientoSeleccionado == nil {
                    ListaMovimientos(
                        movimientoViewModel: movimientoViewModel,
                        amortizacionViewModel: movimientoViewModel,
                        ventaId: ventaId,
                        onMovimientoClick: { movimientoSeleccionado = $0 }
                    )
                } else {
                    DetalleMovimiento(
                        movimiento: movimientoSeleccionado!,
                        onBack: { movimientoSeleccionado = nil }
                    )
                }
            }
            .navigationTitle(movimientoSeleccionado == nil ? "Historial de Pagos" : "Detalle del Pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(hex: "1A1A1A"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("logo_alpha_02")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - ListaMovimientos

struct ListaMovimientos: View {
    @ObservedObject var movimientoViewModel: InmuebleViewModel
    @ObservedObject var amortizacionViewModel: InmuebleViewModel
    let ventaId: String
    var onMovimientoClick: (Movimiento) -> Void

    @State private var proximoPago: String? = nil
    @State private var movimientos: [Movimiento] = []

    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()

            if movimientoViewModel.isLoading {
                // ── Loading ──────────────────────────────────────────
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color(hex: "1A1A1A"))
                    Text("Cargando...")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "888888"))
                }

            } else if let errorMessage = movimientoViewModel.errorMessage {
                // ── Error ────────────────────────────────────────────
                EstadoTarjeta(
                    iconName: "exclamationmark.triangle",
                    iconColor: Color(hex: "E53935"),
                    iconBg: Color(hex: "FFF3F3"),
                    titulo: "Algo salió mal",
                    descripcion: "No se pudieron cargar los movimientos.",
                    boton: {
                        Button {
                            Task {
                                do {
                                    _ = try await movimientoViewModel.getMovimientosInmueble(ventaId: ventaId, onSuccess: { fetched in movimientos = fetched }, onError: { error in movimientoViewModel.errorMessage = error.localizedDescription })
                                } catch { }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                                Text("Reintentar")
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "1A1A1A"))
                            .cornerRadius(10)
                        }
                    }
                )

            } else if movimientos.isEmpty {
                // ── Vacío ────────────────────────────────────────────
                EstadoTarjeta(
                    iconName: "receipt",
                    iconColor: Color(hex: "9E9E9E"),
                    iconBg: Color(hex: "F5F5F5"),
                    titulo: "Sin movimientos",
                    descripcion: "Aún no hay movimientos registrados para esta venta."
                )

            } else {
                // ── Contenido ────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 0) {
                        if let primero = movimientos.first {
                            ResumenPagos(
                                montoTotal: primero.monto_total,
                                montoPagado: primero.monto_pagado,
                                montoPendiente: primero.monto_pendiente,
                                clienteNombre: primero.cliente_nombre,
                                proyecto: primero.proyecto_nombre,
                                numeroInmueble: primero.numero_inmueble,
                                proximoPago: proximoPago
                            )
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(movimientos, id: \.id) { movimiento in
                                TarjetaMovimiento(movimiento: movimiento) {
                                    onMovimientoClick(movimiento)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .task {
            do {
                let proximo = try await movimientoViewModel.getProximoPago(ventaId: ventaId)
                proximoPago = proximo.proximo_pago
            } catch {
                print("Error próximo pago: \(error.localizedDescription)")
            }

            do {
                let fetched = try await movimientoViewModel.getMovimientosInmueble(
                    ventaId: ventaId,
                    onSuccess: { _ in },
                    onError: { _ in }
                )
                movimientos = fetched
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - EstadoTarjeta (empty/error helper)

struct EstadoTarjeta<Boton: View>: View {
    let iconName: String
    let iconColor: Color
    let iconBg: Color
    let titulo: String
    let descripcion: String
    var boton: (() -> Boton)? = nil

    init(iconName: String, iconColor: Color, iconBg: Color,
         titulo: String, descripcion: String,
         @ViewBuilder boton: @escaping () -> Boton) {
        self.iconName = iconName; self.iconColor = iconColor
        self.iconBg = iconBg; self.titulo = titulo
        self.descripcion = descripcion; self.boton = boton
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            .overlay(
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(iconBg).frame(width: 72, height: 72)
                        Image(systemName: iconName)
                            .font(.system(size: 32))
                            .foregroundColor(iconColor)
                    }
                    Text(titulo)
                        .font(.headline).fontWeight(.semibold)
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .multilineTextAlignment(.center)
                    Text(descripcion)
                        .font(.caption)
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 4)
                    boton?()
                }
                .padding(32)
            )
            .padding(24)
    }
}

extension EstadoTarjeta where Boton == EmptyView {
    init(iconName: String, iconColor: Color, iconBg: Color,
         titulo: String, descripcion: String) {
        self.init(iconName: iconName, iconColor: iconColor, iconBg: iconBg,
                  titulo: titulo, descripcion: descripcion, boton: { EmptyView() })
    }
}

// MARK: - ResumenPagos

struct ResumenPagos: View {
    let montoTotal: String
    let montoPagado: String
    let montoPendiente: String
    let clienteNombre: String
    let proyecto: String
    let numeroInmueble: String
    let proximoPago: String?

    var body: some View {
        let progreso = (Double(montoPagado) ?? 0) / max((Double(montoTotal) ?? 1), 1)

        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1A1A1A"))

            VStack(alignment: .leading, spacing: 0) {

                Text(clienteNombre)
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.white)

                Text("\(proyecto) - #\(numeroInmueble)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 2)

                Spacer().frame(height: 20)

                ProgressView(value: progreso)
                    .tint(Color(hex: "4CAF50"))
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)

                Spacer().frame(height: 8)

                Text("\(Int(progreso * 100))% completado")
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))

                Spacer().frame(height: 20)
                Divider().background(Color.white.opacity(0.2))
                Spacer().frame(height: 20)

                VStack(alignment: .leading, spacing: 16) {
                    ResumenItem(label: "Monto total",       monto: montoTotal,     color: .white)
                    ResumenItem(label: "Monto pagado", monto: montoPagado,    color: Color(hex: "4CAF50"))
                    ResumenItem(label: "Monto pendiente",     monto: montoPendiente, color: Color(hex: "FF5252"))
                    ResumenItem(label: "Próximo pago",       monto: proximoPago,    color: .white, esMoneda: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
        .padding(16)
    }
}

// MARK: - ResumenItem

struct ResumenItem: View {
    let label: String
    let monto: String?
    let color: Color
    var esMoneda: Bool = true

    private var displayText: String {
        guard let monto, !monto.isEmpty else { return "—" }
        if esMoneda, let value = Double(monto) {
            return value.toCurrencyString()
        }
        return monto
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text(displayText)
                .font(.title3).fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - TarjetaMovimiento

struct TarjetaMovimiento: View {
    let movimiento: Movimiento
    let onClick: () -> Void

    private var tipoColor: Color {
        switch movimiento.tipo {
        case "Abono": return Color(hex: "4CAF50")
        case "Cargo": return Color(hex: "FF5252")
        default:      return Color(hex: "2196F3")
        }
    }

    private var tipoIcon: String {
        switch movimiento.tipo {
        case "Abono": return "arrow.down"
        case "Cargo": return "arrow.up"
        default:      return "pencil"
        }
    }

    var body: some View {
        Button(action: onClick) {
            VStack(spacing: 12) {
                // Fila 1: icono + monto + chips
                HStack {
                    ZStack {
                        Circle()
                            .fill(tipoColor.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: tipoIcon)
                            .foregroundColor(tipoColor)
                            .font(.title3)
                    }

                    if let valor = Double(movimiento.monto) {
                        Text(String(format: valor.toCurrencyString()))
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(tipoColor)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        ChipMovimiento(text: movimiento.tipo, backgroundColor: tipoColor)
                        ChipMovimiento(text: movimiento.forma_pago, backgroundColor: Color(hex: "607D8B"))
                    }
                }

                // Fila 2: fecha + referencia
                HStack {
                    Text(formatearFecha(movimiento.fecha))
                        .font(.caption).fontWeight(.medium)
                        .foregroundColor(Color(hex: "666666"))
                    Spacer()
                    Text("Ref: \(movimiento.referencia)")
                        .font(.caption).fontWeight(.medium)
                        .foregroundColor(Color(hex: "666666"))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(hex: "F5F5F5"))
                        .cornerRadius(6)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ChipMovimiento

struct ChipMovimiento: View {
    let text: String
    let backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.caption2).fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

// MARK: - DetalleMovimiento

struct DetalleMovimiento: View {
    let movimiento: Movimiento
    var onBack: () -> Void

    private var tipoColor: Color {
        switch movimiento.tipo {
        case "Abono": return Color(hex: "4CAF50")
        case "Cargo": return Color(hex: "FF5252")
        default:      return Color(hex: "2196F3")
        }
    }

    private var tipoIcon: String {
        switch movimiento.tipo {
        case "Abono": return "checkmark.circle"
        case "Cargo": return "exclamationmark.triangle"
        default:      return "info.circle"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // ── Header ────────────────────────────────────────────
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .overlay(
                        LinearGradient(
                            colors: [Color(hex: "1A1A1A"), Color(hex: "2D2D2D")],
                            startPoint: .top, endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: tipoIcon)
                                    .font(.system(size: 64))
                                    .foregroundColor(tipoColor)
                                if let valor = Double(movimiento.monto) {
                                    Text(valor.toCurrencyString())
                                        .font(.largeTitle).fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                Text(movimiento.tipo)
                                    .font(.body).fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20).padding(.vertical, 8)
                                    .background(tipoColor)
                                    .cornerRadius(20)
                            }
                            .padding(24)
                        )
                    )
                    .frame(height: 260)

                // ── Detalles del Pago ─────────────────────────────────
                SeccionDetalle(titulo: "Detalles del Pago") {
                    DetalleRow(label: "Referencia", value: movimiento.referencia, systemIcon: "info.circle")
                    DetalleRow(label: "Forma de Pago", value: movimiento.forma_pago, systemIcon: "creditcard")
                    DetalleRow(label: "Fecha", value: formatearFechaCompleta(movimiento.fecha), systemIcon: "calendar")
                    DetalleRow(label: "ID Transacción", value: movimiento.id, systemIcon: "star")
                }

                // ── Info del Cliente ──────────────────────────────────
                SeccionDetalle(titulo: "Información del Cliente") {
                    DetalleRow(label: "Cliente", value: movimiento.cliente_nombre, systemIcon: "person")
                    DetalleRow(label: "Documento", value: movimiento.cliente_documento, systemIcon: "envelope")
                }

                // ── Info del Inmueble ─────────────────────────────────
                SeccionDetalle(titulo: "Información del Inmueble") {
                    DetalleRow(label: "Proyecto", value: movimiento.proyecto_nombre, systemIcon: "house")
                    DetalleRow(label: "Número", value: movimiento.numero_inmueble, systemIcon: "wrench")
                }

                // ── Estado Financiero ─────────────────────────────────
                SeccionDetalle(titulo: "Estado Financiero") {
                    EstadoFinancieroRow(label: "Monto Total", monto: movimiento.monto_total, color: Color(hex: "1A1A1A"))
                    EstadoFinancieroRow(label: "Monto Pagado", monto: movimiento.monto_pagado, color: Color(hex: "4CAF50"))
                    EstadoFinancieroRow(label: "Monto Pendiente", monto: movimiento.monto_pendiente, color: Color(hex: "FF5252"))

                    let progreso = (Double(movimiento.monto_pagado) ?? 0) / (Double(movimiento.monto_total) ?? 1)
                    ProgressView(value: progreso)
                        .tint(Color(hex: "4CAF50"))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.top, 8)
                    Text("\(Int(progreso * 100))% completado")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(Color(hex: "4CAF50"))
                }
            }
            .padding(16)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
}

// MARK: - SeccionDetalle

struct SeccionDetalle<Content: View>: View {
    let titulo: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo)
                .font(.title2).fontWeight(.bold)
                .foregroundColor(Color(hex: "1A1A1A"))
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - DetalleRow

struct DetalleRow: View {
    let label: String
    let value: String
    let systemIcon: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F5F5F5"))
                    .frame(width: 40, height: 40)
                Image(systemName: systemIcon)
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(hex: "666666"))
                Text(value)
                    .font(.body).fontWeight(.medium)
                    .foregroundColor(Color(hex: "1A1A1A"))
            }
        }
    }
}

// MARK: - EstadoFinancieroRow

struct EstadoFinancieroRow: View {
    let label: String
    let monto: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(Color(hex: "666666"))
            Spacer()
            if let valor = Double(monto) {
                Text(valor.toCurrencyString())
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
    }
}



extension Double {
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        return "$\(formatter.string(from: NSNumber(value: self)) ?? "0.00")"
    }
}


