//
//  LoginViewModel.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//


// LoginViewModel.swift

import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var loginResponse: LoginResponse? = nil
    @Published var userSAPResponse: UserSAPResponse? = nil
    @Published var profileResponse: ProfileResponse? = nil

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase = LoginUseCase()) {
        self.loginUseCase = loginUseCase
    }

    func clearData() {
        loginResponse = nil
        errorMessage = nil
    }

    // MARK: - Async helpers (internos)

    func iniciarSesion(email: String, password: String) async throws -> LoginResponse {
        let result = await loginUseCase.execute(email: email, password: password)
        switch result {
        case .success(let response):
            loginResponse = response
            return response
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func recoverUserSAP(userId: String) async throws -> UserSAPResponse{
        // SAP es opcional: si falla, no bloqueamos el flujo
        let result = await loginUseCase.getSAPUserData(userId: userId)
        switch result {
        case .success(let user):
            userSAPResponse = user
            UserDefaults.standard.set(user.client_id, forKey: "cardCode")
            UserDefaults.standard.set(user.sap_customer_number, forKey: "sapCustomerNumber")
            UserDefaults.standard.set(user.id, forKey: "sapUserId")
            return user
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
        
    }

    func recoverProfile(userId: String) async throws -> ProfileResponse {
        let result = await loginUseCase.getProfileData(userId: userId)
        switch result {
        case .success(let profile):
            profileResponse = profile
            return profile
        case .failure(let error):
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
