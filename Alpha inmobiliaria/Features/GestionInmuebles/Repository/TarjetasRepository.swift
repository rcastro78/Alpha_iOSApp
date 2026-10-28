```swift
//
//  TarjetasRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 21/10/26.
//

import Foundation

class TarjetasRepository {

    private let api: AlphaAPIService

    init(api: AlphaAPIService = .shared) {
        self.api = api
    }

    // MARK: - Guardar tarjeta tokenizada

    func guardarTarjeta(
        request: GuardarTarjetaRequest
    ) async -> Result<GuardarTarjetaResponse, Error> {

        do {
            let response = try await api.guardarTarjeta(
                cardCode: request.cardCode,
                proyectoId: request.proyectoId,
                token: request.token,
                tarjetaEnmascarada: request.tarjetaEnmascarada,
                ultimos4: request.ultimos4,
                marca: request.marca,
                mesVenc: request.mesVenc,
                anioVenc: request.anioVenc,
                alias: request.alias,
                nombreTitular: request.nombreTitular,
                apellidoTitular: request.apellidoTitular,
                identificacion: request.identificacion,
                direccion: request.direccion,
                email: request.email,
                telefono: request.telefono
            )

            guard response.success else {
                let errorMsg = response.error
                    ?? "No se pudo guardar la tarjeta"

                return .failure(
                    NSError(
                        domain: "TarjetasRepository",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg
                        ]
                    )
                )
            }

            return .success(response)

        } catch {
            return .failure(error)
        }
    }

    // MARK: - Listar tarjetas guardadas

    func listarTarjetas(
        cardCode: String,
        proyectoId: String
    ) async -> Result<[TarjetaGuardada], Error> {

        do {
            let response = try await api.listarTarjetas(
                cardCode: cardCode,
                proyectoId: proyectoId
            )

            guard response.success else {
                let errorMsg = response.error
                    ?? "No se pudieron cargar las tarjetas"

                return .failure(
                    NSError(
                        domain: "TarjetasRepository",
                        code: 2,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg
                        ]
                    )
                )
            }

            return .success(response.tarjetas ?? [])

        } catch {
            return .failure(error)
        }
    }

    // MARK: - Obtener token de tarjeta

    func obtenerTokenTarjeta(
        tarjetaId: Int64,
        cardCode: String,
        proyectoId: String
    ) async -> Result<String, Error> {

        do {
            let response = try await api.obtenerTokenTarjeta(
                tarjetaId: tarjetaId,
                cardCode: cardCode,
                proyectoId: proyectoId
            )

            guard response.success,
                  let token = response.token,
                  !token.trimmingCharacters(
                    in: .whitespacesAndNewlines
                  ).isEmpty else {

                let errorMsg = response.error
                    ?? "No se pudo recuperar la tarjeta"

                return .failure(
                    NSError(
                        domain: "TarjetasRepository",
                        code: 3,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg
                        ]
                    )
                )
            }

            return .success(token)

        } catch {
            return .failure(error)
        }
    }

    // MARK: - Eliminar tarjeta guardada

    func eliminarTarjeta(
        tarjetaId: Int64,
        cardCode: String
    ) async -> Result<EliminarTarjetaResponse, Error> {

        do {
            let response = try await api.eliminarTarjeta(
                tarjetaId: tarjetaId,
                cardCode: cardCode
            )

            guard response.success else {
                let errorMsg = response.error
                    ?? "No se pudo eliminar la tarjeta"

                return .failure(
                    NSError(
                        domain: "TarjetasRepository",
                        code: 4,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg
                        ]
                    )
                )
            }

            return .success(response)

        } catch {
            return .failure(error)
        }
    }
}
```