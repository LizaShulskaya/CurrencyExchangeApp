import CoreModels

public protocol ExchangeRateProvider {
    func fetchRates(base: Currency) async throws -> ExchangeRate
}
