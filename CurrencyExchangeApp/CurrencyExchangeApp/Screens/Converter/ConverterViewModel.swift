import SwiftUI
import SwiftData
import CurrencyRateService
import CurrencyAPI
import CurrencyDatabase

@MainActor
final class ConverterViewModel: ObservableObject {

    // Хранилище пользовательских настроек
    private var settingsStorage: UserSettingsStorage
    
    private let apiService: CurrencyAPIService

    // Исходная валюта
    @Published var fromCurrency: Currency {
        didSet { settingsStorage.lastUsedFromCurrency = fromCurrency }
    }
    // Целевая валюта
    @Published var toCurrency: Currency {
        didSet { settingsStorage.lastUsedToCurrency = toCurrency }
    }

    init(settingsStorage: UserSettingsStorage) {
        self.settingsStorage = settingsStorage
        let savedFrom = settingsStorage.lastUsedFromCurrency
        let savedTo = settingsStorage.lastUsedToCurrency
        self._fromCurrency = Published(initialValue: savedFrom)
        self._toCurrency = Published(initialValue: savedTo)
        
        do {
            let config = try AppProperties.getConfig()
            self.apiService = CurrencyAPIService(apiKey: config.apiKey, baseURL: config.baseURL)
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
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
    
    func convert(context: ModelContext) async {
        errorMessage = nil
        result = nil
        rate = nil
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = Strings.errorInvalidAmount
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let databaseService = CurrencyDatabaseService(context: context)
        let currencyRateService = CurrencyRateServiceProvider(
            apiService: apiService,
            databaseService: databaseService
        )
        
        do {
            let conversion = try await currencyRateService.convertWithSave(
                amount: amountValue,
                from: fromCurrency,
                to: toCurrency,
                context: context
            )
            self.result = conversion.result
            self.rate = conversion.rate
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
