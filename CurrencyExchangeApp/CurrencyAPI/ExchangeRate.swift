/**
 Модель, представляющая курсы валют по отношению к одной базовой валюте.
 Используется для декодирования ответа от API и хранения курса каждой валюты в виде словаря.
 */
public struct ExchangeRate: Codable {
    
    // Словарь курсов валют, где ключ — код валюты (например, "USD", "EUR"), а значение — курс по отношению к базовой валюте.
    public let rates: [String: Double]

    public init(rates: [String: Double]) {
        self.rates = rates
    }

    enum CodingKeys: String, CodingKey {
        case rates = "data"
    }
}
