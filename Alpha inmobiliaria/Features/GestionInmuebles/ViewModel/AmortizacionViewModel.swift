//
//  AmortizacionViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 6/4/26.
//
import Foundation
import Combine

@MainActor
public class AmortizacionViewModel:ObservableObject{
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var amortizacionesResponse: AmortizacionResponse? = nil
    
    private let amortizacionRepository: AmortizacionRepository
    
    init(amortizacionRepository: AmortizacionRepository) {
        self.amortizacionRepository = amortizacionRepository
    }
    
    
    
    func getAmortizaciones(ventaId:String) async throws -> AmortizacionResponse{
        let result = await self.amortizacionRepository.getAmortizaciones(ventaId: ventaId)
        self.isLoading = false
        switch result{
        case .success(let response):
            self.amortizacionesResponse = response
            return response
        case .failure(let error):
            print("Error amortizaciones: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    
    
    
}
