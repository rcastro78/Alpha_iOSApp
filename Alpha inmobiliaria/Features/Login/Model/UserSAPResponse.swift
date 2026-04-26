//
//  UserSAPResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//


struct UserSAPResponse: Codable {
    let client_id: String
    let created_at: String
    let id: String
    let last_sync_at: String?
    let sap_customer_number: String?
    let sap_sync_status: String
    let updated_at: String
}