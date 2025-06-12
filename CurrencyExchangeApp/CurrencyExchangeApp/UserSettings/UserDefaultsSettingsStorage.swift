import Foundation
import CurrencyAPI


/**
 Реализация хранилища на основе UserDefaults.
 */
public final class UserDefaultsSettingsStorage: UserSettingsStorage {
    private let fromKey = "fromCurrency"
    private let toKey = "toCurrency"

    public init() {}

    public var lastUsedFromCurrency: Currency {
        get {
            let raw = UserDefaults.standard.string(forKey: fromKey) ?? Currency.USD.rawValue
            return Currency(rawValue: raw) ?? .USD
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: fromKey)
        }
    }

    public var lastUsedToCurrency: Currency {
        get {
            let raw = UserDefaults.standard.string(forKey: toKey) ?? Currency.RUB.rawValue
            return Currency(rawValue: raw) ?? .RUB
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: toKey)
        }
    }
}
