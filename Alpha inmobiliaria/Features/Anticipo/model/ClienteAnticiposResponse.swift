import Foundation

// MARK: - ClienteAnticiposResponse

struct ClienteAnticiposResponse: Codable, Hashable {
    
    let odataMetadata: String
    let value: [ValueAnticipoResponse]
    
    enum CodingKeys: String, CodingKey {
        case odataMetadata = "odata.metadata"
        case value
    }
}

// MARK: - ValueAnticipoResponse

struct ValueAnticipoResponse: Codable, Hashable, Identifiable {
    
    var id: Int { DocEntry }
    
    let Address: String
    let Address2: String
    let AddressExtension: AddressExtension
    let AuthorizationStatus: String
    let CancelStatus: String
    let CardCode: String
    let CardName: String
    let ClosingOption: String
    let Comments: String
    let CommissionTrade: String
    let Confirmed: String
    let ContactPersonCode: Int
    let ControlAccount: String
    let CreationDate: String
    let DataVersion: Int
    let DocCurrency: String
    let DocDate: String
    let DocDueDate: String
    let DocEntry: Int
    let DocNum: Int
    let DocObjectCode: String
    let DocRate: Int
    let DocTime: String
    let DocTotal: Double
    let DocTotalSys: Double
    let DocType: String
    let DocumentDelivery: String
    let DocumentInstallments: [DocumentInstallment]
    let DocumentLines: [DocumentLine]
    let DocumentStatus: String
    let DocumentSubType: String
    let DownPayment: Double
    let DownPaymentAmount: Double
    let DownPaymentAmountSC: Double
    let DownPaymentPercentage: Double
    let DownPaymentStatus: String
    let DownPaymentType: String
    let EDocGenerationType: String
    let EDocStatus: String
    let ExtraMonth: Int
    let FatherType: String
    let FederalTaxID: String
    let FinancialPeriod: Int
    let InterimType: String
    let InventoryStatus: String
    let IssuingReason: Int
    let JournalMemo: String
    let LanguageCode: Int
    let NumberOfInstallments: Int
    let OpenForLandedCosts: String
    let PartialSupply: String
    let PayToCode: String
    let PaymentGroupCode: Int
    let PeriodIndicator: String
    let Printed: String
    let Reference1: String
    let RelatedType: Int
    let SalesPersonCode: Int
    let SequenceModel: String
    let Series: Int
    let ShipFrom: String
    let ShipToCode: String
    let StartFrom: String
    let SummeryType: String
    let TaxDate: String
    let TaxExtension: TaxExtension
    let TransNum: Int
    let TransportationCode: Int
    let U_Status: String
    let U_TIPO_NC: String
    let UpdateDate: String
    let UpdateTime: String
    let UserSign: Int
    let WareHouseUpdateType: String
    let odataEtag: String
    
    enum CodingKeys: String, CodingKey {
        case Address
        case Address2
        case AddressExtension
        case AuthorizationStatus
        case CancelStatus
        case CardCode
        case CardName
        case ClosingOption
        case Comments
        case CommissionTrade
        case Confirmed
        case ContactPersonCode
        case ControlAccount
        case CreationDate
        case DataVersion
        case DocCurrency
        case DocDate
        case DocDueDate
        case DocEntry
        case DocNum
        case DocObjectCode
        case DocRate
        case DocTime
        case DocTotal
        case DocTotalSys
        case DocType
        case DocumentDelivery
        case DocumentInstallments
        case DocumentLines
        case DocumentStatus
        case DocumentSubType
        case DownPayment
        case DownPaymentAmount
        case DownPaymentAmountSC
        case DownPaymentPercentage
        case DownPaymentStatus
        case DownPaymentType
        case EDocGenerationType
        case EDocStatus
        case ExtraMonth
        case FatherType
        case FederalTaxID
        case FinancialPeriod
        case InterimType
        case InventoryStatus
        case IssuingReason
        case JournalMemo
        case LanguageCode
        case NumberOfInstallments
        case OpenForLandedCosts
        case PartialSupply
        case PayToCode
        case PaymentGroupCode
        case PeriodIndicator
        case Printed
        case Reference1
        case RelatedType
        case SalesPersonCode
        case SequenceModel
        case Series
        case ShipFrom
        case ShipToCode
        case StartFrom
        case SummeryType
        case TaxDate
        case TaxExtension
        case TransNum
        case TransportationCode
        case U_Status
        case U_TIPO_NC
        case UpdateDate
        case UpdateTime
        case UserSign
        case WareHouseUpdateType
        case odataEtag = "odata.etag"
    }
}