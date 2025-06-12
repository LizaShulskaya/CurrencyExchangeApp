import Foundation

public final class CurrencyAPIService {
    private let apiKey: String
    private let baseURL: URL
    
    public init(apiKey: String,
                baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    public func fetchRates(base: Currency) async throws -> ExchangeRate {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "base_currency", value: base.rawValue)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ExchangeRate.self, from: data)
    }
}
