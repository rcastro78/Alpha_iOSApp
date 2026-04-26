//
//  AlphaAPIService.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//
// Equivale a IAlphaInmobiliariaAPI.kt

import Foundation
class AlphaAPIService {
    static let shared = AlphaAPIService()
    private init() {}
    
    func login(email: String, password: String) async throws -> LoginResponse {
        return try await NetworkClient.shared.request(
            endpoint: "login.php",
            body: ["email": email, "encrypted_password": password],
            responseType: LoginResponse.self
        )
    }
    
    func getUserSAP(userId: String) async throws -> UserSAPResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getUserIdSAP.php",
            body: ["userId": userId],
            responseType: UserSAPResponse.self
        )
    }
    
    //Proyectos
    func getProjects() async throws -> ProyectoResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getProyectos.php",
            body: [:],
            responseType: ProyectoResponse.self
        )
    }
    
    
    //Profile
    func getProfile(userId: String) async throws -> ProfileResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getProfile.php",
            body: ["userId": userId],
            responseType: ProfileResponse.self
        )
    }
    
    //Inmuebles
    func getInmuebles(clienteId: String) async throws -> InmuebleResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getInmuebles.php",
            body: ["clienteId": clienteId],
            responseType: InmuebleResponse.self)
                
    }
    
    //Movimientos del inmueble
    func getMovimientosInmueble(ventaId: String) async throws -> MovimientoResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getMovimientos.php",
            body: ["ventaId": ventaId],
            responseType: MovimientoResponse.self)
                
    }
    
    //Amortizaciones
    func getAmortizaciones(ventaId: String) async throws -> AmortizacionResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getAmortizaciones.php",
            body: ["ventaId": ventaId],
            responseType: AmortizacionResponse.self)
                
    }
    
    //Proximo pago
    func getProximoPago(ventaId: String) async throws -> ProximoPagoResponse {
        return try await NetworkClient.shared.request(
            endpoint: "getProximoPago.php",
            body: ["ventaId": ventaId],
            responseType: ProximoPagoResponse.self)
    }
    
    
    func registerUser(
        email: String,
        password: String,
        nombre: String,
        documento: String,
        direccion: String,
        telefono: String,
        foto: Data? = nil
    ) async throws -> ClientRegisterResponse {
        return try await NetworkClient.shared.multipartRequest(
            endpoint: "userRegister.php",
            fields: [
                "email":     email,
                "password":  password,
                "nombre":    nombre,
                "documento": documento,
                "direccion": direccion,
                "telefono":  telefono
            ],
            imageData: foto,
            imageName: "foto",
            responseType: ClientRegisterResponse.self
        )
    }
    
    func crearClienteSAP(
        db: String,
        body: NewClientSAPRequest
    ) async throws -> NewClientSAPResponse {
        
        return try await NetworkClient.shared.requestJSON(
            endpoint: "api/v1/sap/Clientes/",
            method: "POST",
            headers: [
                "X-DB": db
            ],
            body: body,
            responseType: NewClientSAPResponse.self
        )
    }
    
    
    
    
}
