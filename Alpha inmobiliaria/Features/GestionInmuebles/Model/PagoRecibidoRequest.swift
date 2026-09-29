struct PagoRecibidoRequest: Codable {
    let cardCode: String
    let docDate: String
    let journalRemarks: String
    let paymentInvoices: [PaymentInvoice]
    let remarks: String
    let transferAccount: String
    let transferDate: String
    let transferReference: String
    let transferSum: Double

    enum CodingKeys: String, CodingKey {
        case cardCode = "CardCode"
        case docDate = "DocDate"
        case journalRemarks = "JournalRemarks"
        case paymentInvoices = "PaymentInvoices"
        case remarks = "Remarks"
        case transferAccount = "TransferAccount"
        case transferDate = "TransferDate"
        case transferReference = "TransferReference"
        case transferSum = "TransferSum"
    }
}

struct PaymentInvoice: Codable {
    let docEntry: Int
    let invoiceType: String
    let sumApplied: Double

    enum CodingKeys: String, CodingKey {
        case docEntry = "DocEntry"
        case invoiceType = "InvoiceType"
        case sumApplied = "SumApplied"
    }
}