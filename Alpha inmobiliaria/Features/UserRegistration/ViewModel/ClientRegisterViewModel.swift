//
//  ClientRegisterViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//
import Foundation
import Combine

@MainActor
class ClientRegisterViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var clientRegisterResponse: ClientRegisterResponse? = nil

    private let repository: ClientRegisterRepository

    init(repository: ClientRegisterRepository = ClientRegisterRepository()) {
        self.repository = repository
    }

    func register(
        email: String,
        password: String,
        nombre: String,
        documento: String,
        direccion: String,
        telefono: String,
        foto: Data? = nil
    ) {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            let result = await repository.register(
                email: email,
                password: password,
                nombre: nombre,
                documento: documento,
                direccion: direccion,
                telefono: telefono,
                foto: foto
            )

            switch result {
            case .success(let response):
                clientRegisterResponse = response
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
