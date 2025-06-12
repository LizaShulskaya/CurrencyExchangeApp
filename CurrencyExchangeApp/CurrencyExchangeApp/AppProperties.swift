import Foundation

struct AppProperties: Codable {
    let apiKey: String
    let baseURL: URL
    let cacheTimeout: TimeInterval

    static func getConfig(from filename: String = "Config") throws -> AppProperties {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(domain: "ConfigError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Config file \(filename).json not found"])
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(AppProperties.self, from: data)
    }
}
