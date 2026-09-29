import Foundation

struct AddressExtension: Codable, Identifiable, Hashable {
    
    var id: Int { DocEntry }
    
    let BillToCity: String
    let BillToCountry: String
    let BillToStreet: String
    let DocEntry: Int
    let ShipToCountry: String
}