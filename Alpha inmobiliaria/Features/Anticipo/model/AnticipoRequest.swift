import Foundation

// MARK: - AnticipoRequest

struct AnticipoRequest: Codable, Hashable {
    
    let docSubType: String
    let docType: String
    let downPaymentType: String
    let cardCode: String
    let docCurrency: String
    let docDate: String
    let docDueDate: String
    let taxDate: String
    let u_IDApart: String?
    let comments: String?
    let journalMemo: String?
    let documentLines: [DocumentLineAnticipo]
    
    init(
        cardCode: String,
        docDate: String,
        docDueDate: String,
        taxDate: String,
        u_IDApart: String? = "0",
        comments: String? = nil,
        journalMemo: String? = nil,
        documentLines: [DocumentLineAnticipo],
        docSubType: String = "dn",
        docType: String = "dDocument_Items",
        downPaymentType: String = "dptInvoice",
        docCurrency: String = "USD"
    ) {
        self.docSubType = docSubType
        self.docType = docType
        self.downPaymentType = downPaymentType
        self.cardCode = cardCode
        self.docCurrency = docCurrency
        self.docDate = docDate
        self.docDueDate = docDueDate
        self.taxDate = taxDate
        self.u_IDApart = u_IDApart
        self.comments = comments
        self.journalMemo = journalMemo
        self.documentLines = documentLines
    }
    
    enum CodingKeys: String, CodingKey {
        case docSubType
        case docType
        case downPaymentType
        case cardCode
        case docCurrency
        case docDate
        case docDueDate
        case taxDate
        case u_IDApart
        case comments
        case journalMemo
        case documentLines
    }
}

// MARK: - DocumentLineAnticipo

struct DocumentLineAnticipo: Codable, Hashable, Identifiable {
    
    var id: UUID = UUID()
    
    let itemCode: String
    let quantity: Int
    let unitPrice: Double
    let taxCode: String
    let projectCode: String
    
    enum CodingKeys: String, CodingKey {
        case itemCode
        case quantity
        case unitPrice
        case taxCode
        case projectCode
    }
}