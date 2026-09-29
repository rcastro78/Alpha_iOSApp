import SwiftUI

public struct ReciboView: View {
    public let data: ReciboData

    public init(data: ReciboData) {
        self.data = data
    }

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height

            VStack(alignment: .leading, spacing: 8) {
                // Header
                VStack(alignment: .center, spacing: 4) {
                    Text(data.empresa)
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)
                    Text(data.sociedad)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    Text("\(data.emisorDireccion) • Tel: \(data.emisorTelefono)")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 12)

                HStack {
                    Text("Recibo No: \(data.numeroRecibo)")
                        .font(.subheadline)
                    Spacer()
                    Text(data.fecha)
                        .font(.subheadline)
                }
                .padding(.bottom, 12)

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Group {
                        HStack {
                            Text("Recibo de:")
                                .bold()
                            Spacer()
                            Text(data.reciboDe)
                        }
                        HStack {
                            Text("Pago realizado por:")
                                .bold()
                            Spacer()
                            Text(data.pagoRealizadoPor)
                        }
                        HStack {
                            Text("Identificación pagador:")
                                .bold()
                            Spacer()
                            Text(data.identificacionPagador)
                        }
                        HStack {
                            Text("Email pagador:")
                                .bold()
                            Spacer()
                            Text(data.emailPagador)
                        }
                        HStack {
                            Text("Nombre propietario:")
                                .bold()
                            Spacer()
                            Text(data.nombrePropietario)
                        }
                        HStack {
                            Text("Identificación receptor:")
                                .bold()
                            Spacer()
                            Text(data.identificacionReceptor)
                        }
                        HStack {
                            Text("Email receptor:")
                                .bold()
                            Spacer()
                            Text(data.emailReceptor)
                        }
                    }
                    Divider().padding(.vertical, 4)
                    Group {
                        HStack {
                            Text("Nombre proyecto:")
                                .bold()
                            Spacer()
                            Text(data.nombreProyecto)
                        }
                        HStack {
                            Text("Unidad:")
                                .bold()
                            Spacer()
                            Text(data.unidad)
                        }
                        HStack {
                            Text("Ubicación:")
                                .bold()
                            Spacer()
                            Text(data.ubicacion)
                        }
                        HStack {
                            Text("Nivel:")
                                .bold()
                            Spacer()
                            Text(data.nivel)
                        }
                        HStack {
                            Text("Cantidad en letras:")
                                .bold()
                            Spacer()
                            Text(data.cantidadLetras)
                        }
                        HStack {
                            Text("Concepto:")
                                .bold()
                            Spacer()
                            Text(data.concepto)
                        }
                        HStack {
                            Text("Referencia banco:")
                                .bold()
                            Spacer()
                            Text(data.referenciaBanco)
                        }
                        HStack {
                            Text("Wompi Transaction ID:")
                                .bold()
                            Spacer()
                            Text(data.wompiTransactionId)
                        }
                    }
                    Divider().padding(.vertical, 4)
                    Group {
                        HStack {
                            Text("Precio anterior:")
                                .bold()
                            Spacer()
                            Text(data.precioAnterior)
                        }
                        HStack {
                            Text("Saldo anterior:")
                                .bold()
                            Spacer()
                            Text(data.saldoAnterior)
                        }
                        HStack {
                            Text("Monto pago:")
                                .bold()
                            Spacer()
                            Text(data.montoPago)
                        }
                        HStack {
                            Text("Nuevo saldo:")
                                .bold()
                            Spacer()
                            Text(data.nuevoSaldo)
                        }
                    }
                    Divider().padding(.vertical, 4)
                    Group {
                        HStack(spacing: 20) {
                            Text("Efectivo: \(data.efectivo)")
                            Text("Transferencia: \(data.transferencia)")
                            Text("Tarjeta: \(data.tarjeta)")
                        }
                        .font(.subheadline)

                        HStack {
                            Text("Tipo de pago:")
                                .bold()
                            Spacer()
                            Text(data.tipoPago)
                        }

                        HStack {
                            Text("Asesor:")
                                .bold()
                            Spacer()
                            Text(data.asesor)
                        }
                    }
                }
                .font(.footnote)
                .padding(.horizontal, 4)

                Spacer()

                HStack {
                    Spacer()
                    Text("Monto USD: \(data.montoUsd)")
                        .font(.title2.bold())
                }
            }
            .padding(20)
            .foregroundColor(.black)
            .background(Color.white)
            .frame(width: width, height: height, alignment: .topLeading)
        }
        .frame(minWidth: 816, minHeight: 528)
        .background(Color.white)
    }
}

#Preview {
    struct DummyReciboData: ReciboData {
        var empresa: String = "Empresa XYZ S.A."
        var sociedad: String = "Sociedad Limitada"
        var emisorDireccion: String = "123 Calle Falsa, Ciudad"
        var emisorTelefono: String = "+1234567890"
        var fecha: String = "2026-05-01"
        var montoUsd: String = "$1,200.00"
        var reciboDe: String = "Juan Pérez"
        var pagoRealizadoPor: String = "Juan Pérez"
        var identificacionPagador: String = "123456789"
        var emailPagador: String = "juan.perez@email.com"
        var nombrePropietario: String = "Juan Pérez"
        var identificacionReceptor: String = "987654321"
        var emailReceptor: String = "recepcion@empresa.com"
        var nombreProyecto: String = "Proyecto Edificio Central"
        var unidad: String = "A-101"
        var ubicacion: String = "Sector 5"
        var nivel: String = "3"
        var cantidadLetras: String = "Mil doscientos dólares"
        var concepto: String = "Pago cuota mensual"
        var referenciaBanco: String = "REF123456789"
        var wompiTransactionId: String = "WOMPI-987654321"
        var precioAnterior: String = "$5,000.00"
        var saldoAnterior: String = "$3,800.00"
        var montoPago: String = "$1,200.00"
        var nuevoSaldo: String = "$2,600.00"
        var efectivo: String = "$0.00"
        var transferencia: String = "$1,200.00"
        var tarjeta: String = "$0.00"
        var asesor: String = "Carlos Gómez"
        var numeroRecibo: String = "000123"
        var tipoPago: String = "Transferencia bancaria"
    }

    ReciboView(data: DummyReciboData())
        .frame(width: 816, height: 528)
}
