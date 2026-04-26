//
//  LoginResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//


struct LoginResponse: Codable {
    let message: String
    let success: Bool
    let user: User
}
