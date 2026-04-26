//
//  ProyectoRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//
class ProyectoRepository {
    private let api: AlphaAPIService

    init(api: AlphaAPIService = .shared) {
        self.api = api
    }

    func getProyectos() async throws -> ProyectoResponse {
        return try await api.getProjects()
    }
}
