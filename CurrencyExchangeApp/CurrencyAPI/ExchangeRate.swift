public struct ExchangeRate: Codable {
    public let rates: [String: Double]

    public init(rates: [String: Double]) {
        self.rates = rates
    }

    enum CodingKeys: String, CodingKey {
        case rates = "data"
    }
}
