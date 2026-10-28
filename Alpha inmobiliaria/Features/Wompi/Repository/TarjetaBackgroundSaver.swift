// MARK: - Guardado en segundo plano (equivale a SaveCardBackgroundRepository)

/// Vive fuera de la vista: si el cliente sale de la pantalla durante la
/// tokenización, el guardado continúa. Un fallo NUNCA afecta al pago ya aprobado.
final class TarjetaBackgroundSaver {
    static let shared = TarjetaBackgroundSaver()
    private init() {}

    private struct TimeoutError: Error {}

    /// `onFallo` se invoca en el hilo principal (equivale al Toast de `avisarFallo`).
    func guardar(clientId: String,
                 clientSecret: String,
                 request: TokenizacionRequest,
                 construirRequest: @escaping (TokenizacionResponse) -> GuardarTarjetaRequest,
                 onFallo: (@MainActor () -> Void)? = nil) {
        Task.detached(priority: .utility) { [self] in
            do {
                try await conTimeout(segundos: 120) {
                    // 1) token de acceso (wompiRepository.getTokenWompi)
                    let accessToken = try await self.obtenerAccessToken(clientId: clientId,
                                                                        clientSecret: clientSecret)
                    // 2) tokenizar (wompiRepository.tokenizeCard)
                    let resp = try await self.tokenizar(accessToken: accessToken, request: request)
                    // 3) guardar en backend (tarjetasRepository.guardarTarjeta)
                    try await self.guardarEnBackend(construirRequest(resp))
                }
                print("[GuardadoTarjetas] Tarjeta guardada")
            } catch is CancellationError {
                return
            } catch is TimeoutError {
                await self.avisarFallo("Tiempo de espera agotado", onFallo)
            } catch {
                await self.avisarFallo("\(type(of: error)): \(error.localizedDescription)", onFallo)
            }
        }
    }

    private func avisarFallo(_ motivo: String, _ onFallo: (@MainActor () -> Void)?) async {
        print("[GuardadoTarjetas] No se pudo guardar la tarjeta: \(motivo)") // sin datos de tarjeta
        await MainActor.run { onFallo?() }
    }

    // MARK: Timeout (equivale a withTimeout(120_000))
    private func conTimeout(segundos: Double, _ operacion: @escaping () async throws -> Void) async throws {
        try await withThrowingTaskGroup(of: Void.self) { grupo in
            grupo.addTask { try await operacion() }
            grupo.addTask {
                try await Task.sleep(nanoseconds: UInt64(segundos * 1_000_000_000))
                throw TimeoutError()
            }
            _ = try await grupo.next()
            grupo.cancelAll()
        }
    }

    // MARK: Pasos (si ya tienes estos repositorios en iOS, llama a los tuyos aquí)

    private func obtenerAccessToken(clientId: String, clientSecret: String) async throws -> String {
        var auth = URLRequest(url: URL(string: TarjetasAPIConfig.wompiAuthURL)!)
        auth.httpMethod = "POST"
        auth.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        auth.httpBody = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)&audience=wompi_api"
            .data(using: .utf8)
        let (data, _) = try await URLSession.shared.data(for: auth)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let token = json["access_token"] as? String else {
            throw TarjetasError.respuestaInvalida   // "Token nulo"
        }
        return token
    }

    private func tokenizar(accessToken: String, request: TokenizacionRequest) async throws -> TokenizacionResponse {
        guard let url = URL(string: TarjetasAPIConfig.wompiTokenizacionURL) else {   // TODO
            throw TarjetasError.respuestaInvalida
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(request)
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw TarjetasError.http(http.statusCode)
        }
        return try JSONDecoder().decode(TokenizacionResponse.self, from: data)
    }

    private func guardarEnBackend(_ body: GuardarTarjetaRequest) async throws {
        guard let url = URL(string: TarjetasAPIConfig.backendBaseURL + "/tarjetas") else {   // TODO ruta
            throw TarjetasError.respuestaInvalida
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        TarjetasAPIConfig.headersBackend().forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = try JSONEncoder().encode(body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw TarjetasError.http(http.statusCode)
        }
    }
}