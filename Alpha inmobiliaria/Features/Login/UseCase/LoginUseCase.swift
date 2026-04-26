//
//  LoginUseCase.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//


class LoginUseCase {
    private let repository: LoginRepository
    
    init(repository: LoginRepository = LoginRepository()) {
        self.repository = repository
    }
    
    func execute(email: String, password: String) async -> Result<LoginResponse, Error> {
        return await repository.iniciarSesion(email: email, password: password)
    }
    
    func getSAPUserData(userId: String) async -> Result<UserSAPResponse, Error> {
        return await repository.recoverSAPUser(userId: userId)
    }
    
    func getProfileData(userId: String) async -> Result<ProfileResponse, Error> {
        return await repository.getProfile(userId: userId)
    }
}
