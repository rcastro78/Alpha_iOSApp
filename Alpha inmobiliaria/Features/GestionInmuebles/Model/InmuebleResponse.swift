//
//  InmuebleResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 31/3/26.
//
import SwiftUI

// Disambiguation helper in case other modules define Inmueble
// Use AppInmueble in other files if ambiguity persists
// typealias AppInmueble = Inmueble

extension Inmueble: Identifiable {
    var id: String { inmueble_id }
}


struct InmuebleResponse: Codable {
    let inmuebles: [Inmueble]
    let success: Bool
}

struct Inmueble:Codable{
    let cliente_id: String
    let direccion: String 
    let estado: String 
    let inmueble_id: String 
    let monto_cuota: String 
    let monto_pagado: String 
    let monto_pendiente: String 
    let monto_prima: String 
    let monto_total: String 
    let nombre_proyecto: String 
    let numero_inmueble: String 
    let plazo_meses: String 
    let proyecto_id: String 
    let tipo_proyecto: String 
    let ubicacion: String 
    let venta_id: String 
    let public_key: String?
    let private_key: String?
    let id_sap_cliente: String?
    let xdb: String?
    let pagadas: String
    let color_oscuro: String 
    let color_medio: String 
    let color_brillante: String
}
// MARK: - Example usage (commented)
// let decoder = JSONDecoder()
// let response = try decoder.decode(InmuebleResponse.self, from: data)
// let items: [Inmueble] = response.inmuebles

