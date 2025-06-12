import SwiftData

/**
 Модель записи истории конвертации валют.
 */
@Model
public final class ConversionHistoryRecord {
    @Attribute(.unique) public var id: UUID = UUID()
    public var fromCurrency: String
    public var toCurrency: String
    public var amount: Double
    public var result: Double
    public var rate: Double
    public var date: Date

    /**
   Инициализатор для создания новой записи истории.
     
     - parameters:
        - fromCurrency: Исходная валюта.
        - toCurrency: Целевая валюта.
        - amount: Конвертируемая сумма.
        - result: Результат конвертации.
        - rate: Курс конвертации.
        - date: Дата и время (по умолчанию — текущая).
     */
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
