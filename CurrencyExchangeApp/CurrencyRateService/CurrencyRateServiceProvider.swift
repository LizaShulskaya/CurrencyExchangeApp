import SwiftData
import CurrencyAPI
import CurrencyDatabase

/**
 Сервис предоставляющий актуальные валютные курсы. Работает с кешем.
 */
public final class CurrencyRateServiceProvider {
    private let apiService: CurrencyAPIService
    private let databaseService: CurrencyDatabaseService
    private let cacheTimeout: TimeInterval
    
    /**
     / Инициализирует сервис курсов валют.
     - parameters:
        - apiService: Сервис, реализующий запросы к внешнему API.
        - databaseService: Сервис работы с локальной базой данных (SwiftData).
        - cacheTimeout: Время жизни кеша в секундах. По умолчанию 60 секунд.
     */
    public init(apiService: CurrencyAPIService,
                databaseService: CurrencyDatabaseService,
                cacheTimeout: TimeInterval = 60) {
        self.apiService = apiService
        self.databaseService = databaseService
        self.cacheTimeout = cacheTimeout
    }
    
    /**
     Получение курсов валют с учётом кеша
     - parameters:
        - base: Базовая валюта, относительно которой нужны курсы.
     - returns: Модель `ExchangeRate`, содержащая словарь курсов.
     - throws: Ошибка, если данные недоступны ни в API, ни в кеше.
     */
    public func getRates(base: Currency) async throws -> ExchangeRate {
        let cachedRate = try? databaseService.fetchCache(base: base)
        
        // Если кэш свежий
        if let cachedRate, Date().timeIntervalSince(cachedRate.updatedAt) < cacheTimeout {
            return ExchangeRate(rates: cachedRate.rates)
        }
        
        do {
            // Если кэш устарел - выполняем запрос к апи
            let freshRates = try await apiService.fetchRates(base: base)
            try databaseService.saveRates(base: base, rates: freshRates)
            return freshRates
        } catch {
            // Возвращаем устаревший кэш, если API не доступен
            if let cachedRate {
                return ExchangeRate(rates: cachedRate.rates)
            }
            throw error
        }
    }
    
    /**
     Выполняет конвертацию валюты и сохраняет результат в историю.
     Получает актуальный курс, вычисляет результат и сохраняет данные в `ConversionHistoryRecord` в SwiftData.
     
     - parameters:
        - amount: Сумма, которую нужно сконвертировать.
        - from: Исходная валюта.
        - to: Целевая валюта.
     - returns: Кортеж с результатом конверсии и используемым курсом.
     - throws: Ошибка, если не удалось получить курс или сохранить данные.
     */
    public func convertWithSave(amount: Double,
                                from: Currency,
                                to: Currency) async throws -> (result: Double, rate: Double) {
        let exchangeRate = try await getRates(base: from)
        
        guard let foundRate = exchangeRate.rates[to.rawValue] else {
            throw NSError(
                domain: "CurrencyRateServiceError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Rate for \(to.rawValue) not found"]
            )
        }
        
        let conversionResult = amount * foundRate
        
        let record = ConversionHistoryRecord(
            fromCurrency: from.rawValue,
            toCurrency: to.rawValue,
            amount: amount,
            result: conversionResult,
            rate: foundRate
        )
        
        try databaseService.saveConversion(record)

        return (conversionResult, foundRate)
    }

}

