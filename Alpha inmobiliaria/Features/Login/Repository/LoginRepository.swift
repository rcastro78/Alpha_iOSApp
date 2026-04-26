//
//  LoginRepository.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//


class LoginRepository {
    private let api: AlphaAPIService
    
    init(api: AlphaAPIService = .shared) {
        self.api = api
    }
    
    func iniciarSesion(email: String, password: String) async -> Result<LoginResponse, Error> {
        do {
            let response = try await api.login(email: email, password: password)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func recoverSAPUser(userId: String) async -> Result<UserSAPResponse, Error> {
        do {
            let response = try await api.getUserSAP(userId: userId)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    func getProfile(userId:String) async -> Result<ProfileResponse,Error> {
        do {
            let response = try await api.getProfile(userId: userId)
            return .success(response)
        }catch {
            return .failure(error)
        }
    }
    
    //Profile
    /*
     suspend fun getProfile(userId: String): Result<ProfileResponse> {
             return try {
                 val response = iAlphaInmobiliariaAPI.getProfile(userId).awaitResponse()
                 if (response.isSuccessful) {
                     Result.success(response.body()!!)
                 } else {
                     Result.failure(Exception("Error en la respuesta del servidor"))
                 }
             } catch (e: Exception) {
                 Result.failure(e)
             }
         }
     */
    
    
}
