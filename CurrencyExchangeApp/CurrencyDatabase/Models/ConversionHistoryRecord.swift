import SwiftData

@Model
public final class ConversionHistoryRecord {
    @Attribute(.unique) public var id: UUID = UUID()
    public var fromCurrency: String
    public var toCurrency: String
    public var amount: Double
    public var result: Double
    public var rate: Double
    public var date: Date

    public init(
        fromCurrency: String,
        toCurrency: String,
        amount: Double,
        result: Double,
        rate: Double,
        date: Date = Date()
    ) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.amount = amount
        self.result = result
        self.rate = rate
        self.date = date
    }
}
