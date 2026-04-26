//
//  AmortizacionRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 6/4/26.
//
class AmortizacionRepository{
    private let api: AlphaAPIService
    
    init(api: AlphaAPIService = .shared) {
        self.api = api
    }
    
    func getAmortizaciones(ventaId:String) async -> Result<AmortizacionResponse, Error> {
        do {
            let response = try await api.getAmortizaciones(ventaId: ventaId)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
}
