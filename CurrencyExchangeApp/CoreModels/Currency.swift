public enum Currency: String, CaseIterable, Codable, Identifiable {
    case USD, EUR, RUB, GBP, CHF, CNY

    public var id: String { rawValue }

    public var flag: String {
        switch self {
        case .USD: return "🇺🇸"
        case .EUR: return "🇪🇺"
        case .RUB: return "🇷🇺"
        case .GBP: return "🇬🇧"
        case .CHF: return "🇨🇭"
        case .CNY: return "🇨🇳"
        }
    }
}
