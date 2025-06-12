import Foundation

struct AppProperties {
    static let shared = AppProperties()

    let apiKey: String

    private init() {
        if let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String {
            apiKey = key
        } else {
            fatalError("API_KEY is missing in Info.plist")
        }
    }
}
