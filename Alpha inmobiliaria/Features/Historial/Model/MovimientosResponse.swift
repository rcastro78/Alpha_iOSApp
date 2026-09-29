//
//  MovimientosResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 21/9/26.
//


import Foundation

// MARK: - MovimientoResponse
struct MovimientosResponse: Codable {
    let movimientos: [Movimiento]?
    let success: Bool
}

// MARK: - Movimiento
struct Movimiento: Codable, Identifiable, Hashable {
    let cliente_documento: String
    let cliente_nombre: String
    let created_at: String
    let fecha: String
    let forma_pago: String
    let id: String
    let monto: String
    let monto_pagado: String
    let monto_pendiente: String
    let monto_total: String
    let numero_inmueble: String
    let proyecto_nombre: String
    let recibo: String
    let referencia: String
    let tipo: String
    let venta_id: String
    let numero_recibo: Int?
}