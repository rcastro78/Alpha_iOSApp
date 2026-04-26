//
//  ProfileResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//

struct ProfileResponse: Codable {
    let profile: Profile
    let success: Bool
}

struct Profile: Codable {
    //let email: String
    let id: String
    let nombre: String
    let telefono: String
    let tipo_documento_id: String
    let documento: String
}

