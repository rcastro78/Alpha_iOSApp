//
//  NewClientSAPResponse.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//


struct NewClientSAPResponse: Codable {
    let address: String?
    let balance: String?
    let balanceFC: String?
    let balanceSys: String?
    let cardCode: String
    let cardFName: String?
    let cardName: String
    let cardType: String
    let cellular: String
    let city: String?
    let country: String
    let county: String?
    let creditLine: String?
    let currency: String
    let debtLine: String?
    let defaultCur: String?
    let discount: String?
    let e_Mail: String?
    let fax: String?
    let federalTaxID: String
    let groupCode: Int
    let groupNum: String?
    let licTradNum: String?
    let phone1: String
    let phone2: String?
    let rfc: String?
    let series: Int
    let slpCode: String?
    let streetNo: String?
    let territory: String?
    let u_EJJE_CodActiv: String?
    let u_NIT: String?
    let u_TipoCons: String?
    let u_TipoCont: String?
    let u_TipoSN: String
    let validFor: String?
    let validFrom: String?
    let validTo: String?
    let vatGroup: String?
    let zipCode: String?
}