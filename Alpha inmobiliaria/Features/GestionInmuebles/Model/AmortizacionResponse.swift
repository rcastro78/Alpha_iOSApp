//
//  AmortizacionResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 1/4/26.
//
struct AmortizacionResponse:Codable {
    let amortizaciones: [Amortizacion]
    let success: Bool
}


struct Amortizacion: Codable {
    let balanceEstimado: String
    let createdAt: String
    let estadoPago: String
    let fechaEstimada: String
    let fechaReal: String?
    let id: String
    let montoCapital: String
    let montoCuota: String
    let montoExceso: String
    let montoInteres: String
    let montoPagadoAcumulado: String
    let montoReal: String?
    let movimientoId: String?
    let numeroPago: String
    let saldoPendiente: String
    let tipoPago: String
    let updatedAt: String
    let ventaId: String

    enum CodingKeys: String, CodingKey {
        case balanceEstimado = "balance_estimado"
        case createdAt = "created_at"
        case estadoPago = "estado_pago"
        case fechaEstimada = "fecha_estimada"
        case fechaReal = "fecha_real"
        case id
        case montoCapital = "monto_capital"
        case montoCuota = "monto_cuota"
        case montoExceso = "monto_exceso"
        case montoInteres = "monto_interes"
        case montoPagadoAcumulado = "monto_pagado_acumulado"
        case montoReal = "monto_real"
        case movimientoId = "movimiento_id"
        case numeroPago = "numero_pago"
        case saldoPendiente = "saldo_pendiente"
        case tipoPago = "tipo_pago"
        case updatedAt = "updated_at"
        case ventaId = "venta_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        balanceEstimado = try container.decode(String.self, forKey: .balanceEstimado)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        estadoPago = try container.decode(String.self, forKey: .estadoPago)
        fechaEstimada = try container.decode(String.self, forKey: .fechaEstimada)
        fechaReal = try container.decodeIfPresent(String.self, forKey: .fechaReal) ?? ""
        id = try container.decode(String.self, forKey: .id)
        montoCapital = try container.decode(String.self, forKey: .montoCapital)
        montoCuota = try container.decode(String.self, forKey: .montoCuota)
        montoExceso = try container.decode(String.self, forKey: .montoExceso)
        montoInteres = try container.decode(String.self, forKey: .montoInteres)
        montoPagadoAcumulado = try container.decode(String.self, forKey: .montoPagadoAcumulado)
        montoReal = try container.decodeIfPresent(String.self, forKey: .montoReal) ?? "0"
        movimientoId = try container.decodeIfPresent(String.self, forKey: .movimientoId) ?? "0"
        numeroPago = try container.decode(String.self, forKey: .numeroPago)
        saldoPendiente = try container.decode(String.self, forKey: .saldoPendiente)
        tipoPago = try container.decode(String.self, forKey: .tipoPago)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        ventaId = try container.decode(String.self, forKey: .ventaId)
    }
}
