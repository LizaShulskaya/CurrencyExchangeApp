import SwiftData
import CoreModels
import Core

public final class CachedExchangeRateService: ExchangeRateProvider {
    public let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchRates(base: Currency) async throws -> ExchangeRate {
        let request = FetchDescriptor<ExchangeRateCache>(predicate: #Predicate { $0.baseCurrency == base.rawValue })
        if let cache = try context.fetch(request).first {
            return try JSONDecoder().decode(ExchangeRate.self, from: cache.rates)
        } else {
            throw NSError(domain: "CacheError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cache not found"])
        }
    }

    public func saveRates(base: Currency, rates: ExchangeRate) throws {
        let data = try JSONEncoder().encode(rates)
        let request = FetchDescriptor<ExchangeRateCache>(predicate: #Predicate { $0.baseCurrency == base.rawValue })
        let oldCaches = try context.fetch(request)
        for oldCache in oldCaches {
            context.delete(oldCache)
        }
        let newCache = ExchangeRateCache(baseCurrency: base.rawValue, rates: data)
        context.insert(newCache)
        try context.save()
    }
}
