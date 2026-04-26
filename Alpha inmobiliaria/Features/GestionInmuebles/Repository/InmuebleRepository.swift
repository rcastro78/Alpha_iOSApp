//
//  InmuebleRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 31/3/26.
//
class InmuebleRepository {
    private let api: AlphaAPIService
    
    init(api: AlphaAPIService = .shared) {
        self.api = api
    }
    
    
    func getInmuebles(clientId:String) async -> Result<InmuebleResponse, Error> {
        do {
            let response = try await api.getInmuebles(clienteId: clientId)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getMovimientosInmueble(ventaId:String) async -> Result<MovimientoResponse, Error> {
        do {
            let response = try await api.getMovimientosInmueble(ventaId: ventaId)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    
    
    
    func getProximoPago(ventaId:String) async -> Result<ProximoPagoResponse, Error> {
        do {
            let response = try await api.getProximoPago(ventaId: ventaId)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
}
