```swift
//
//  TarjetasViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 21/10/26.
//

import Foundation
import Combine

@MainActor
public class TarjetasViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: TarjetasRepository

    init(repository: TarjetasRepository) {
        self.repository = repository
    }

    func listar(
        cardCode: String,
        proyectoId: String,
        onSuccess: @escaping ([TarjetaGuardada]) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            let result = await repository.listarTarjetas(
                cardCode: cardCode,
                proyectoId: proyectoId
            )

            isLoading = false

            switch result {
            case .success(let tarjetas):
                onSuccess(tarjetas)

            case .failure(let error):
                errorMessage = error.localizedDescription
                onError(error)
            }
        }
    }

    func guardar(
        request: GuardarTarjetaRequest,
        onSuccess: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            let result = await repository.guardarTarjeta(
                request: request
            )

            isLoading = false

            switch result {
            case .success:
                onSuccess()

            case .failure(let error):
                errorMessage = error.localizedDescription
                onError(error)
            }
        }
    }

    func obtenerToken(
        tarjetaId: Int64,
        cardCode: String,
        proyectoId: String,
        onSuccess: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            let result = await repository.obtenerTokenTarjeta(
                tarjetaId: tarjetaId,
                cardCode: cardCode,
                proyectoId: proyectoId
            )

            isLoading = false

            switch result {
            case .success(let token):
                onSuccess(token)

            case .failure(let error):
                errorMessage = error.localizedDescription
                onError(error)
            }
        }
    }
}
```