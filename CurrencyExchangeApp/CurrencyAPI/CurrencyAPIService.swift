import CoreModels
import Core

public final class CurrencyAPIService: ExchangeRateProvider {
    public static let shared = CurrencyAPIService()

    private let apiKey = "fca_live_qMlCLQVHXfpdx57jDuOVZnZ34nZsHle5N66UGJT1"
    private let baseURL = "https://api.freecurrencyapi.com/v1/latest"

    public func fetchRates(base: Currency) async throws -> ExchangeRate {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "base_currency", value: base.rawValue)
        ]

        let (data, _) = try await URLSession.shared.data(from: components.url!)
        print(String(data: data, encoding: .utf8))
        return try JSONDecoder().decode(ExchangeRate.self, from: data)
    }
}
