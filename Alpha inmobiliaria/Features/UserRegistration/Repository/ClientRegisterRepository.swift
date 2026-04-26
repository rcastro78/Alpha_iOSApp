//
//  ClientRegisterRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//

import Foundation
class ClientRegisterRepository {
    private let api: AlphaAPIService
    
    init(api: AlphaAPIService = .shared) {
        self.api = api
    }
    
    func register(
        email: String,
        password: String,
        nombre: String,
        documento: String,
        direccion: String,
        telefono: String,
        foto: Data? = nil
    ) async -> Result<ClientRegisterResponse, Error> {
        do {
            let response = try await api.registerUser(
                email: email,
                password: password,
                nombre: nombre,
                documento: documento,
                direccion: direccion,
                telefono: telefono,
                foto: foto
            )
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
