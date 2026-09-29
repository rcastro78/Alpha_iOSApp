import SwiftUI
import PDFKit
import UIKit

// MARK: - MODELOS

struct EstadoCuentaData: Codable {
    let clienteCodigo: String
    let unidad: String
    let nombreCliente: String
    let fechaElaboracion: String
    let precioInmueble: Double
    let primaEntregada: Double
    let saldo: Double
    let telefono: String
    let correo: String
}

struct MovimientoEstadoCuenta: Codable, Identifiable {
    let id = UUID()
    let fecha: String
    let recibo: String
    let abono: Double
    let saldo: Double
}

// MARK: - GENERADOR PDF

final class EstadoCuentaPDF {

    static func exportarEstadoCuenta(
        suggestedFileName: String,
        data: EstadoCuentaData,
        movimientos: [MovimientoEstadoCuenta],
        logoIzquierdo: UIImage?,
        logoDerecho: UIImage?
    ) -> URL? {

        let fileName = sanitizeFileName(suggestedFileName)
        let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        generarPDF(
            url: url,
            data: data,
            movimientos: movimientos,
            logoIzquierdo: logoIzquierdo,
            logoDerecho: logoDerecho
        )

        return url
    }

    static func generarPDF(
        url: URL,
        data: EstadoCuentaData,
        movimientos: [MovimientoEstadoCuenta],
        logoIzquierdo: UIImage?,
        logoDerecho: UIImage?
    ) {

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 36

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()

                let cg = context.cgContext

                let headerColor = UIColor(red: 180/255, green: 185/255, blue: 210/255, alpha: 1)
                let tableHeaderColor = UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 1)

                // MARK: HEADER
                cg.setFillColor(headerColor.cgColor)
                cg.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: 64))

                logoIzquierdo?.draw(in: CGRect(x: margin, y: 8, width: 48, height: 48))
                logoDerecho?.draw(in: CGRect(x: pageRect.width - margin - 48, y: 8, width: 48, height: 48))

                drawCentered(
                    "ALPHA INMOBILIARIA",
                    y: 18,
                    font: .systemFont(ofSize: 10),
                    color: .white,
                    pageWidth: pageRect.width
                )

                drawCentered(
                    "ESTADO DE CUENTA",
                    y: 36,
                    font: .boldSystemFont(ofSize: 16),
                    color: .white,
                    pageWidth: pageRect.width
                )

                // Banda gris
                cg.setFillColor(UIColor(white: 0.94, alpha: 1).cgColor)
                cg.fill(CGRect(x: 0, y: 64, width: pageRect.width, height: 28))

                drawText("Unidad: \(data.unidad)", x: margin, y: 72)
                drawRightText(
                    "Fecha: \(data.fechaElaboracion)",
                    x: pageRect.width - margin,
                    y: 72
                )

                var y: CGFloat = 115

                // MARK: CLIENTE
                drawBold("CLIENTE (SAP): \(data.clienteCodigo)", x: margin, y: y)
                y += 18

                drawText(data.nombreCliente, x: margin, y: y)
                y += 28

                // MARK: SALDOS
                drawBold("PRECIO DEL INMUEBLE:", x: margin, y: y)
                drawText("$ \(money(data.precioInmueble))", x: margin + 180, y: y)
                y += 18

                drawBold("PRIMA ENTREGADA:", x: margin, y: y)
                drawText("$ \(money(data.primaEntregada))", x: margin + 180, y: y)
                y += 18

                drawBold("SALDO:", x: margin, y: y)
                drawText("$ \(money(data.saldo))", x: margin + 180, y: y)
                y += 30

                // MARK: TABLA
                cg.setFillColor(tableHeaderColor.cgColor)
                cg.fill(CGRect(x: margin, y: y, width: pageRect.width - margin * 2, height: 18))

                drawWhite("FECHA", x: margin + 4, y: y + 4)
                drawWhite("RECIBO", x: margin + 130, y: y + 4)
                drawWhite("ABONO", x: margin + 250, y: y + 4)
                drawWhite("SALDO", x: margin + 390, y: y + 4)

                y += 22

                var totalAbonos: Double = 0
                var acumulado: Double = 0

                for item in movimientos {
                    acumulado += item.abono
                    totalAbonos += item.abono

                    let saldoFrac = max(data.precioInmueble - acumulado, 0)

                    drawText(item.fecha, x: margin + 4, y: y)
                    drawText(item.recibo, x: margin + 130, y: y)
                    drawText("$ \(money(item.abono))", x: margin + 250, y: y)
                    drawText("$ \(money(saldoFrac))", x: margin + 390, y: y)

                    y += 18
                }

                y += 10

                drawBold("TOTAL ABONOS:", x: margin + 250, y: y)
                drawBold("$ \(money(totalAbonos))", x: margin + 390, y: y)

                // MARK: FOOTER
                let footerY = pageRect.height - 60

                drawCentered(
                    "Este estado de cuenta es un documento informativo.",
                    y: footerY,
                    font: .systemFont(ofSize: 9),
                    color: .gray,
                    pageWidth: pageRect.width
                )

                drawCentered(
                    "\(data.correo) | Tel: \(data.telefono)",
                    y: footerY + 14,
                    font: .systemFont(ofSize: 9),
                    color: .gray,
                    pageWidth: pageRect.width
                )
            }

        } catch {
            print("Error generando PDF: \(error)")
        }
    }

    // MARK: HELPERS

    static func money(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: value)) ?? "0.00"
    }

    static func sanitizeFileName(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "\\/:*?\"<>|")
        let clean = raw.components(separatedBy: invalid).joined(separator: "_")
        return clean.lowercased().hasSuffix(".pdf") ? clean : clean + ".pdf"
    }

    static func drawText(_ text: String, x: CGFloat, y: CGFloat) {
        text.draw(at: CGPoint(x: x, y: y), withAttributes: [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ])
    }

    static func drawBold(_ text: String, x: CGFloat, y: CGFloat) {
        text.draw(at: CGPoint(x: x, y: y), withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ])
    }

    static func drawWhite(_ text: String, x: CGFloat, y: CGFloat) {
        text.draw(at: CGPoint(x: x, y: y), withAttributes: [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.white
        ])
    }

    static func drawCentered(
        _ text: String,
        y: CGFloat,
        font: UIFont,
        color: UIColor,
        pageWidth: CGFloat
    ) {
        let size = text.size(withAttributes: [.font: font])
        let x = (pageWidth - size.width) / 2

        text.draw(at: CGPoint(x: x, y: y), withAttributes: [
            .font: font,
            .foregroundColor: color
        ])
    }

    static func drawRightText(_ text: String, x: CGFloat, y: CGFloat) {
        let font = UIFont.systemFont(ofSize: 10)
        let size = text.size(withAttributes: [.font: font])

        text.draw(at: CGPoint(x: x - size.width, y: y), withAttributes: [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ])
    }
}