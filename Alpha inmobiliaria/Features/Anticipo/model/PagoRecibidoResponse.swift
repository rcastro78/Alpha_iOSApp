struct PagoRecibidoResponse: Codable {
    let message: String?
    let sap: PagoRecibidoSAPData?
}

struct PagoRecibidoSAPData: Codable {
    let DocEntry: Int?
    let DocNum: Int?
}