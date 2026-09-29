//
//  TaxExtension.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 27/4/26.
//


import Foundation

struct TaxExtension: Codable, Hashable, Identifiable {
    
    var id: Int { DocEntry }
    
    let CityB: String
    let CountryB: String
    let CountryS: String
    let DocEntry: Int
    let ImportOrExportType: String
    let StreetB: String
}