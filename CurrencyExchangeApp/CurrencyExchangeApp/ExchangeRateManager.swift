import CurrencyAPI
import CurrencyDatabase
import CoreModels
import Core
import SwiftData

final class ExchangeRateManager {
    private let apiService: CurrencyAPIService
    private let cacheService: CachedExchangeRateService
    private let cacheTimeout: TimeInterval = 60 

    init(apiService: CurrencyAPIService, cacheService: CachedExchangeRateService) {
        self.apiService = apiService
        self.cacheService = cacheService
    }

    func getRates(base: Currency) async throws -> ExchangeRate {
        do {
            let request = FetchDescriptor<ExchangeRateCache>(predicate: #Predicate { $0.baseCurrency == base.rawValue })
            if let cache = try cacheService.context.fetch(request).first,
               Date().timeIntervalSince(cache.updatedAt) < cacheTimeout {
                return try JSONDecoder().decode(ExchangeRate.self, from: cache.rates)
            }
        } catch {
            
        }

        // Обновляем из сети
        let freshRates = try await apiService.fetchRates(base: base)
        try cacheService.saveRates(base: base, rates: freshRates)
        return freshRates
    }
}
