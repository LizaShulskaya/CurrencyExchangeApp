import SwiftData

/**
 Модель для кэширования курсов валют
 */
@Model
public final class ExchangeRateCache {
    @Attribute(.unique) public var id: UUID = UUID()

    // Код базовой валюты (например, "USD")
    public var baseCurrency: String

    // Словарь курсов относительно базовой валюты
    public var rates: [String: Double]

    // Дата последнего обновления кэша
    public var updatedAt: Date = Date()

    /**
     Инициализатор модели
     - parameters:
        - baseCurrency: код базовой валюты
        - rates: словарь курсов (например, ["EUR": 0.94])
        - updatedAt: дата обновления (по умолчанию сейчас)
     */
    public init(
        baseCurrency: String,
        rates: [String: Double],
        updatedAt: Date = Date()
    ) {
        self.baseCurrency = baseCurrency
        self.rates = rates
        self.updatedAt = updatedAt
    }
}
