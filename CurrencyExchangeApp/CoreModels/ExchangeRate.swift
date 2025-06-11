public struct ExchangeRate: Codable {
    public let rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case rates = "data"
    }
}
