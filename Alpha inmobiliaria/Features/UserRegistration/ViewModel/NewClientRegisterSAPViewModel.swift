//
//  NewClientRegisterSAPViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//

import Foundation
import Combine

@MainActor
class NewClientRegisterSAPViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var newClientSAPResponse: NewClientSAPResponse? = nil
    
    private let repository:NewClientRegisterSAPRepository

    
    init(
        isLoading: Bool = false,
        errorMessage: String? = nil,
        newClientSAPResponse: NewClientSAPResponse? = nil,
        repository: NewClientRegisterSAPRepository = NewClientRegisterSAPRepository()  // ← default
    ) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.newClientSAPResponse = newClientSAPResponse
        self.repository = repository
    }
    
    
    func registerSAPClient(db:String,
                           body:NewClientSAPRequest){
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            
          let result = await repository.registrarClienteSAP(base: db, clienteRequest: body)
            switch result {
            case .success(let response):
                newClientSAPResponse = response
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            
        }
    }
    
    
    
    
}
