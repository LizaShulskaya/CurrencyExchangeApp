import SwiftData

@Model
public final class ExchangeRateCache {
    @Attribute(.unique) public var id: UUID = UUID()
    public var baseCurrency: String
    public var rates: Data // JSON-сериализованные курсы
    public var updatedAt: Date = Date()

    init(baseCurrency: String, rates: Data) {
        self.baseCurrency = baseCurrency
        self.rates = rates
    }
}
