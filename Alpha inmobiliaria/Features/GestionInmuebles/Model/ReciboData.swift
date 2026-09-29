struct ReciboData: Codable {
    let empresa: String
    let sociedad: String
    let emisorDireccion: String
    let emisorTelefono: String
    let fecha: String
    let montoUsd: String
    let reciboDe: String
    let pagoRealizadoPor: String
    let identificacionPagador: String
    let emailPagador: String
    let nombrePropietario: String
    let identificacionReceptor: String
    let emailReceptor: String
    let nombreProyecto: String
    let unidad: String
    let ubicacion: String
    let nivel: String
    let cantidadLetras: String
    let concepto: String
    let referenciaBanco: String
    let wompiTransactionId: String
    let precioAnterior: String
    let saldoAnterior: String
    let montoPago: String
    let nuevoSaldo: String
    let efectivo: String
    let transferencia: String
    let tarjeta: String
    let asesor: String
    let numeroRecibo: Int
    let tipoPago: String

    init(
        empresa: String,
        sociedad: String = "",
        emisorDireccion: String = "",
        emisorTelefono: String = "",
        fecha: String,
        montoUsd: String,
        reciboDe: String,
        pagoRealizadoPor: String,
        identificacionPagador: String = "",
        emailPagador: String = "",
        nombrePropietario: String,
        identificacionReceptor: String = "",
        emailReceptor: String = "",
        nombreProyecto: String = "",
        unidad: String,
        ubicacion: String = "",
        nivel: String,
        cantidadLetras: String,
        concepto: String,
        referenciaBanco: String,
        wompiTransactionId: String = "",
        precioAnterior: String,
        saldoAnterior: String,
        montoPago: String,
        nuevoSaldo: String,
        efectivo: String,
        transferencia: String,
        tarjeta: String,
        asesor: String,
        numeroRecibo: Int,
        tipoPago: String = "cuota"
    ) {
        self.empresa = empresa
        self.sociedad = sociedad
        self.emisorDireccion = emisorDireccion
        self.emisorTelefono = emisorTelefono
        self.fecha = fecha
        self.montoUsd = montoUsd
        self.reciboDe = reciboDe
        self.pagoRealizadoPor = pagoRealizadoPor
        self.identificacionPagador = identificacionPagador
        self.emailPagador = emailPagador
        self.nombrePropietario = nombrePropietario
        self.identificacionReceptor = identificacionReceptor
        self.emailReceptor = emailReceptor
        self.nombreProyecto = nombreProyecto
        self.unidad = unidad
        self.ubicacion = ubicacion
        self.nivel = nivel
        self.cantidadLetras = cantidadLetras
        self.concepto = concepto
        self.referenciaBanco = referenciaBanco
        self.wompiTransactionId = wompiTransactionId
        self.precioAnterior = precioAnterior
        self.saldoAnterior = saldoAnterior
        self.montoPago = montoPago
        self.nuevoSaldo = nuevoSaldo
        self.efectivo = efectivo
        self.transferencia = transferencia
        self.tarjeta = tarjeta
        self.asesor = asesor
        self.numeroRecibo = numeroRecibo
        self.tipoPago = tipoPago
    }
}