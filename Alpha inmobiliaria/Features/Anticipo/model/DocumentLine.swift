import Foundation

struct DocumentLine: Codable, Hashable, Identifiable {
    
    var id: Int { DocEntry }
    
    let AccountCode: String
    let BaseType: Int
    let ChangeAssemlyBoMWarehouse: String
    let CorrectionInvoiceItem: String
    let Currency: String
    let DocEntry: Int
    let Factor1: Double
    let Factor2: Double
    let Factor3: Double
    let Factor4: Double
    let GrossPrice: Double
    let GrossTotal: Double
    let GrossTotalSC: Double
    let InventoryQuantity: Double
    let ItemCode: String
    let ItemDescription: String
    let ItemDetails: String
    let ItemType: String
    let LineStatus: String
    let LineTaxJurisdictions: [LineTaxJurisdiction]
    let LineTotal: Double
    let LineType: String
    let NCMCode: Int
    let OpenAmount: Double
    let OpenAmountSC: Double
    let PackageQuantity: Double
    let PickStatusEx: String
    let Price: Double
    let PriceAfterVAT: Double
    let PriceSource: String
    let ProjectCode: String
    let Quantity: Double
    let RemainingOpenInventoryQuantity: Double
    let RemainingOpenQuantity: Double
    let RowTotalSC: Double
    let SalesPersonCode: Int
    let ShipToCode: String
    let ShipToDescription: String
    let ShippingMethod: Int
    let TaxCode: String
    let TaxLiable: String
    let TaxType: String
    let TreeType: String
    let UnitPrice: Double
    let UnitsOfMeasurment: Double
    let UoMCode: String
    let UoMEntry: Int
    let VolumeUnit: Int
    let WarehouseCode: String
}