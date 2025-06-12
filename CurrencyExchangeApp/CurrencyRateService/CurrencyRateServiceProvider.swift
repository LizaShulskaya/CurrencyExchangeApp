import SwiftData
import CurrencyAPI
import CurrencyDatabase

public final class CurrencyRateServiceProvider {
    private let apiService: CurrencyAPIService
    private let databaseService: CurrencyDatabaseService
    private let cacheTimeout: TimeInterval
    
    public init(
        apiService: CurrencyAPIService,
        databaseService: CurrencyDatabaseService,
        cacheTimeout: TimeInterval = 60
    ) {
        self.apiService = apiService
        self.databaseService = databaseService
        self.cacheTimeout = cacheTimeout
    }
    
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
     Конвертация с сохранением истории
     */
    public func convertWithSave(amount: Double,
                                from: Currency,
                                to: Currency,
                                context: ModelContext) async throws -> (result: Double, rate: Double) {
        let exchangeRate = try await getRates(base: from)
        guard let foundRate = exchangeRate.rates[to.rawValue] else {
            throw NSError(domain: "CurrencyRateServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Rate for \(to.rawValue) not found"])
        }
        let conversionResult = amount * foundRate

        // Сохраняем историю конвертации
        let record = ConversionHistoryRecord(
            fromCurrency: from.rawValue,
            toCurrency: to.rawValue,
            amount: amount,
            result: conversionResult,
            rate: foundRate
        )
        context.insert(record)
        try context.save()

        return (conversionResult, foundRate)
    }
}

