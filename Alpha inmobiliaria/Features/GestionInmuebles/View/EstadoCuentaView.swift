struct EstadoCuentaView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var inmuebleViewModel: InmuebleViewModel
    @ObservedObject var movimientoViewModel: MovimientoViewModel
    @AppStorage("profileId") private var clienteId = ""
    @AppStorage("cardCode")  private var cardCode  = ""
    @AppStorage("name")      private var userName  = ""

    var body: some View {
        NavigationStack {
            ListaEstadoCuentaView(
                inmuebleViewModel: inmuebleViewModel,
                movimientoViewModel: movimientoViewModel,
                clienteId: clienteId,
                cardCode: cardCode,
                userName: userName
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Estado de Cuenta")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(.logoAlpha02)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                }
            }
            .toolbarBackground(Color(hex: "1A1A1A"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// ── LISTA ──
struct ListaEstadoCuentaView: View {
    @ObservedObject var inmuebleViewModel: InmuebleViewModel
    @ObservedObject var movimientoViewModel: MovimientoViewModel
    let clienteId: String
    let cardCode: String
    let userName: String

    var body: some View {
        Group {
            if inmuebleViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if let error = inmuebleViewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                        .foregroundColor(.red)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding(32)

            } else if (inmuebleViewModel.inmuebleResponse?.inmuebles ?? []).isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .foregroundColor(Color(.lightGray))
                    Text("No tienes propiedades")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(32)

            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(inmuebleViewModel.inmuebleResponse?.inmuebles ?? []) { inmueble in
                            TarjetaEstadoCuentaView(
                                inmueble: inmueble,
                                onDownloadClick: {
                                    descargarEstadoCuenta(inmueble: inmueble)
                                }
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F8F9FA"))
        .onAppear {
            inmuebleViewModel.getInmueblesCliente(clienteId)
        }
        .onDisappear {
            inmuebleViewModel.clearData()
        }
    }

    private func descargarEstadoCuenta(inmueble: Inmueble) {
        let ventaId = inmueble.ventaId ?? ""
        guard !ventaId.isEmpty else {
            // Mostrar alerta: sin venta asociada
            return
        }

        movimientoViewModel.getMovimientos(ventaId) { result in
            switch result {
            case .success(let response):
                let movimientos: [MovimientoEstadoCuenta] = (response.movimientos ?? []).map {
                    MovimientoEstadoCuenta(
                        fecha: $0.fecha,
                        recibo: "\($0.numeroRecibo ?? 0)",
                        abono: Double($0.monto) ?? 0,
                        saldo: Double($0.montoPendiente) ?? 0
                    )
                }
                let estadoCuentaData = EstadoCuentaData(
                    clienteCodigo: cardCode,
                    unidad: inmueble.numeroInmueble ?? "",
                    nombreCliente: userName,
                    fechaElaboracion: response.movimientos?.first?.fecha ?? "-",
                    precioInmueble: Double(inmueble.montoTotal ?? "") ?? 0,
                    primaEntregada: Double(inmueble.montoPagado ?? "") ?? 0,
                    saldo: (Double(inmueble.montoTotal ?? "") ?? 0) - (Double(inmueble.montoPagado ?? "") ?? 0),
                    telefono: "2254-8000",
                    correo: "finanzas@alphainmobiliaria.com.sv"
                )
                let imagenProyecto = obtenerImagenProyecto(inmueble.nombreProyecto ?? "")
                EstadoCuentaPdf.exportarEstadoCuenta(
                    data: estadoCuentaData,
                    movimientos: movimientos,
                    imagenProyecto: imagenProyecto,
                    imagenLogo: Image(.logoAlpha02)
                )

            case .failure(let error):
                print("Error al obtener movimientos: \(error)")
            }
        }
    }

    private func obtenerImagenProyecto(_ proyecto: String) -> ImageResource {
        let nombre = proyecto.uppercased()
        switch true {
        case nombre.contains("UNO"):     return .uno
        case nombre.contains("SUNSET"):  return .solaris
        case nombre.contains("SOLARIS"): return .solaris
        case nombre.contains("NU "):     return .nu_lm
        default:                         return .logoAlpha
        }
    }
}

// ── TARJETA ──
struct TarjetaEstadoCuentaView: View {
    let inmueble: Inmueble
    let onDownloadClick: () -> Void

    var gradientColors: [Color] {
        [
            Color(hex: inmueble.colorOscuro ?? "1A1A1A"),
            Color(hex: inmueble.colorMedio ?? "444444"),
            Color(hex: inmueble.colorBrillante ?? "888888")
        ]
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Header con gradiente ──
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 100)

                VStack(alignment: .leading, spacing: 4) {
                    Text(inmueble.nombreProyecto ?? "")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(inmueble.numeroInmueble ?? "")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(16)
            }

            // ── Cuerpo ──
            VStack(spacing: 0) {
                // Ubicación
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundColor(Color(hex: "666666"))
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(inmueble.direccion ?? "")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color(hex: "333333"))
                        Text(inmueble.tipoProyecto ?? "")
                            .font(.caption)
                            .foregroundColor(Color(hex: "999999"))
                    }
                    Spacer()
                }
                .padding(.bottom, 16)

                Divider().background(Color(hex: "EEEEEE"))
                    .padding(.bottom, 16)

                // Valor del inmueble
                HStack {
                    Text("Valor del inmueble")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "666666"))
                    Spacer()
                    Text("$\(String(format: "%,.2f", Double(inmueble.montoTotal ?? "") ?? 0))")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "1A1A1A"))
                }
                .padding(.bottom, 12)

                // Saldo pendiente
                HStack {
                    Text("Saldo pendiente")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "666666"))
                    Spacer()
                    let saldo = (Double(inmueble.montoTotal ?? "") ?? 0) - (Double(inmueble.montoPagado ?? "") ?? 0)
                    Text("$\(String(format: "%,.2f", saldo))")
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "FFA726"))
                }
                .padding(.bottom, 16)

                Divider().background(Color(hex: "EEEEEE"))
                    .padding(.bottom, 16)

                // Botón descargar
                Button(action: onDownloadClick) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Descargar estado de cuenta")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "1A1A1A"))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}