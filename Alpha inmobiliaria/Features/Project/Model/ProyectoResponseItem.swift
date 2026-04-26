//
//  ProyectoResponseItem.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//


typealias ProyectoResponse = [ProyectoResponseItem]

struct ProyectoResponseItem: Codable,Identifiable {
    let color_brillante: String
    let color_medio: String
    let color_oscuro: String
    let created_at: String
    let created_by: String
    let deleted_at: String?
    let deleted_by: String?
    let direccion: String
    let id: String
    let logo_url: String?
    let modified_at: String?
    let modified_by: String?
    let nombre: String
    let sap_id_proyecto: String?
    let sociedad: String
    let xdb: String?
}
