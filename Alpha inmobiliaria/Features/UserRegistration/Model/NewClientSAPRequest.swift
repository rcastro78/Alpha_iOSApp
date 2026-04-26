//
//  NewClientSAPRequest.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//
struct NewClientSAPRequest:Codable{
    let CardName: String
    let CardType: String
    let FederalTaxID: String
    let Series: Int
    let cellular: String
    let phone1: String
}
