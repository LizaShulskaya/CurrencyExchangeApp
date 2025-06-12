import Foundation

/**
 Сервис для получения курсов валют с удалённого API.
 */
public final class CurrencyAPIService {
    
    // API-ключ для аутентификации запросов.
    private let apiKey: String
    
    // Базовый URL API, к которому выполняются запросы.
    private let baseURL: URL
    
    public init(apiKey: String,
                baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    /**
     Загружает актуальные курсы валют по отношению к указанной базовой валюте.
     
     Метод выполняет сетевой запрос к внешнему API
     - parameters:
        - base: Базовая валюта, относительно которой необходимо получить курсы.
     - returns: Объект `ExchangeRate`, содержащий словарь курсов валют.
     - throws: Ошибка `URLError`, если запрос не удался, ответ некорректен или данные не удалось декодировать.
     */
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
