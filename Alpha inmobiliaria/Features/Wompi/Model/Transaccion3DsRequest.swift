struct Transaccion3DsRequest: Codable {
    let apellido: String
    let ciudad: String
    let codigoPostal: String
    let datosAdicionales: String?
    let direccion: String
    let email: String
    let idExterno: String
    let idGrupoTarjetas: String?
    let idPais: String
    let idRegion: String
    let monto: Double
    let nombre: String
    let tarjetaCreditoDebido: TarjetaCreditoDebido
    let telefono: String
    let urlRedirect: String
}

struct TarjetaCreditoDebido: Codable {
    let anioVencimiento: Int
    let cvv: String
    let mesVencimiento: Int
    let numeroTarjeta: String
}