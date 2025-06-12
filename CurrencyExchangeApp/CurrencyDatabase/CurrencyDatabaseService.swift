import SwiftData
import CurrencyAPI

public final class CurrencyDatabaseService {
    public let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    /**
     Возвращает кешированную запись с курсами валют для указанной базовой валюты
     - parameters:
        - base: базовая валюта
     */
    public func fetchCache(base: Currency) throws -> ExchangeRateCache? {
        let request = FetchDescriptor<ExchangeRateCache>(
            predicate: #Predicate { $0.baseCurrency == base.rawValue }
        )
        return try context.fetch(request).first
    }
    
    /**
     Сохраняет курсы в локальное хранилище SwiftData
     - parameters:
        - base: базовая валюта
        - rates: модель ExchangeRate с полем rates: [String: Double]
     */
    public func saveRates(base: Currency, rates: ExchangeRate) throws {
        // Удаляем старые кеш-записи для данной базовой валюты
        let request = FetchDescriptor<ExchangeRateCache>(
            predicate: #Predicate<ExchangeRateCache> { $0.baseCurrency == base.rawValue }
        )
        let oldCaches = try context.fetch(request)
        for cache in oldCaches {
            context.delete(cache)
        }
        // Создаем новую запись с готовым словарем курсов
        let newCache = ExchangeRateCache(
            baseCurrency: base.rawValue,
            rates: rates.rates,
            updatedAt: Date()
        )
        context.insert(newCache)
        try context.save()
    }

}
