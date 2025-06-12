import CurrencyAPI
import CurrencyDatabase
import CoreModels
import Core
import SwiftData


/*
 Менеджер для получения курсов валют с использованием API и локального кэша.
 
 Логика работы:
 При запросе курсов сначала проверяется локальный кэш.
 Если кэш существует и не устарел — возвращается он.
 Если кэш отсутствует или устарел — выполняется запрос к API.
 В случае ошибки при запросе к API, возвращается устаревший кэш, если он есть.
 
 Используется таймаут для кэширования курсов (по умолчанию 60 секунд).
 */
final class ExchangeRateManager {
    private let apiService: CurrencyAPIService
    private let cacheService: CachedExchangeRateService
    private let cacheTimeout: TimeInterval = 60

    init(apiService: CurrencyAPIService, cacheService: CachedExchangeRateService) {
        self.apiService = apiService
        self.cacheService = cacheService
    }

    func getRates(base: Currency) async throws -> ExchangeRate {
        // Сначала пытаемся получить свежий кэш (в пределах таймаута)
        do {
            let request = FetchDescriptor<ExchangeRateCache>(predicate: #Predicate { $0.baseCurrency == base.rawValue })
            if let cache = try cacheService.context.fetch(request).first,
               Date().timeIntervalSince(cache.updatedAt) < cacheTimeout {
                return try JSONDecoder().decode(ExchangeRate.self, from: cache.rates)
            }
        } catch {
        
        }

        // Если кэш устарел или отсутствует, пытаемся получить новые данные из сети
        do {
            let freshRates = try await apiService.fetchRates(base: base)
            try cacheService.saveRates(base: base, rates: freshRates)
            return freshRates
        } catch {
            // При ошибке сети пытаемся вернуть кэш хоть и устаревший
            do {
                let request = FetchDescriptor<ExchangeRateCache>(predicate: #Predicate { $0.baseCurrency == base.rawValue })
                if let fallbackCache = try cacheService.context.fetch(request).first {
                    return try JSONDecoder().decode(ExchangeRate.self, from: fallbackCache.rates)
                }
            } catch {
                
            }
            throw error
        }
    }
}
