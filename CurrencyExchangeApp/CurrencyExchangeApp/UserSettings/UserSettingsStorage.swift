/**
 Хранилище пользовательских данных
 */
public protocol UserSettingsStorage {
    var lastUsedFromCurrency: Currency { get set }
    var lastUsedToCurrency: Currency { get set }
}
