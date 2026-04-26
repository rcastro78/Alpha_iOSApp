//
//  ProyectoViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//
import Foundation
import Combine
@MainActor
public class ProyectoViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var proyectoResponse: ProyectoResponse = []

    var proyectos: [ProyectoResponseItem] { proyectoResponse }

    private let repository: ProyectoRepository

    init(repository: ProyectoRepository) {
        self.repository = repository
    }

    func getProyectos() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                proyectoResponse = try await repository.getProyectos()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
