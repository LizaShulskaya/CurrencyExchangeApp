import SwiftData
import CurrencyAPI

/**
 Сервис для работы с локальным хранилищем курсов валют на базе SwiftData.
 */
public final class CurrencyDatabaseService {
    public let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    /**
     Возвращает кешированную запись с курсами валют для указанной базовой валюты
     - parameters:
        - base: Базовая валюта, относительно которой были сохранены курсы.
     - returns: Объект `ExchangeRateCache`, если найден; иначе — `nil`.
     - throws: Ошибка, если запрос к базе данных завершился ошибкой.
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
        - base: Базовая валюта, к которой относятся переданные курсы.
        - rates: Модель ExchangeRate с полем rates: [String: Double]
     - throws: Ошибка при сохранении.
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

    /**
     Сохраняет запись в историю проведенных операций
     - parameters:
        - record: модель дынных для записи в БД
     */
    public func saveConversion(_ record: ConversionHistoryRecord) throws {
        context.insert(record)
        try context.save()
    }
}
