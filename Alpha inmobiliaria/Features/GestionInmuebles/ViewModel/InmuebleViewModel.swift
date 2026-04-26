//
//  InmuebleViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 31/3/26.
//
import Foundation
import Combine

@MainActor
public class InmuebleViewModel:ObservableObject{
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var inmuebleResponse: InmuebleResponse? = nil
    
    private let inmuebleRepository: InmuebleRepository
    
    init(inmuebleRepository: InmuebleRepository) {
        self.inmuebleRepository = inmuebleRepository
    }
    
    func obtenerInmueble(clienteId: String) async throws -> InmuebleResponse{
        
        await MainActor.run {
                self.errorMessage = nil
                self.isLoading = true
            }
        
        let result = await self.inmuebleRepository.getInmuebles(clientId: clienteId)
        self.isLoading = false
        switch result{
            case .success(let response):
            inmuebleResponse = response
            return inmuebleResponse!
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func getInmueblesCliente(_ clienteId: String,
                             onSuccess: ((InmuebleResponse) -> Void)? = nil,
                             onError: ((Error) -> Void)? = nil) {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            do {
                let inmueblesList = try await inmuebleRepository.getInmuebles(clientId: clienteId).get().inmuebles
                let response = InmuebleResponse(inmuebles: inmueblesList, success: true)
                // Update the published response with the new value instead of trying to mutate inner properties
                self.inmuebleResponse = response
                onSuccess?(response)
            } catch {
                errorMessage = error.localizedDescription
                let response = InmuebleResponse(inmuebles: [], success: false)
                self.inmuebleResponse = response
                onError?(error)
            }

            isLoading = false
        }
    }
    
    func getMovimientosInmueble(ventaId:String, onSuccess: @escaping ([Movimiento]) -> Void, onError: @escaping (Error) -> Void) async throws -> [Movimiento]{
        let result = await self.inmuebleRepository.getMovimientosInmueble(ventaId: ventaId)
        switch result{
        case .success(let response):
            return response.movimientos
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    
    
    func getProximoPago(ventaId:String) async throws -> ProximoPagoResponse{
        let result = await self.inmuebleRepository.getProximoPago(ventaId: ventaId)
        switch result{
        case .success(let response):
            return response
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
}
