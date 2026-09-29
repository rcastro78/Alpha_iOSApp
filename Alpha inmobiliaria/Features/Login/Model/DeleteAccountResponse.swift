struct DeleteAccountResponse: Codable {
    let success: Bool
    let message: String
    let deletedUser: DeletedUser

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case deletedUser = "deleted_user"
    }
}

struct DeletedUser: Codable {
    let id: String
    let email: String
}