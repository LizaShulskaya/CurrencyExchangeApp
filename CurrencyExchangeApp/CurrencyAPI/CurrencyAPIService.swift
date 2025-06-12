import CoreModels
import Core

public final class CurrencyAPIService: ExchangeRateProvider {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"

    public func fetchRates(base: Currency) async throws -> ExchangeRate {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "base_currency", value: base.rawValue)
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        return try JSONDecoder().decode(ExchangeRate.self, from: data)
    }
}
