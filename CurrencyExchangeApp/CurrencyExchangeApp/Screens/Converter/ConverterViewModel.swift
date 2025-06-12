import SwiftUI
import SwiftData
import CurrencyRateService
import CurrencyAPI
import CurrencyDatabase

@MainActor
final class ConverterViewModel: ObservableObject {

    // Хранилище пользовательских настроек
    private var settingsStorage: UserSettingsStorage
    
    private let currencyRateService: CurrencyRateServiceProvider

    // Исходная валюта
    @Published var fromCurrency: Currency {
        didSet { settingsStorage.lastUsedFromCurrency = fromCurrency }
    }
    // Целевая валюта
    @Published var toCurrency: Currency {
        didSet { settingsStorage.lastUsedToCurrency = toCurrency }
    }

    init(settingsStorage: UserSettingsStorage,
         currencyRateService: CurrencyRateServiceProvider) {
        self.settingsStorage = settingsStorage
        self.currencyRateService = currencyRateService
        let savedFrom = settingsStorage.lastUsedFromCurrency
        let savedTo = settingsStorage.lastUsedToCurrency
        self._fromCurrency = Published(initialValue: savedFrom)
        self._toCurrency = Published(initialValue: savedTo)
    }
    
    @Published var amount: String = ""
    @Published private(set) var result: Double?
    @Published private(set) var rate: Double?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    var resultText: String {
        if let result = result {
            return String(format: "%.2f", result)
        } else {
            return "-"
        }
    }
    
    func convert() async {
        errorMessage = nil
        result = nil
        rate = nil
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = Strings.errorInvalidAmount
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let conversion = try await currencyRateService.convertWithSave(
                amount: amountValue,
                from: fromCurrency,
                to: toCurrency
            )
            self.result = conversion.result
            self.rate = conversion.rate
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
