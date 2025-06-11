import SwiftUI
import SwiftData
import CoreModels
import CurrencyAPI
import CurrencyDatabase

@MainActor
final class ConverterViewModel: ObservableObject {
   
    @Published var fromCurrency: Currency = .USD
    @Published var toCurrency: Currency = .RUB
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
    
    private let apiService = CurrencyAPIService.shared
    
    func convert(context: ModelContext) async {
        errorMessage = nil
        result = nil
        rate = nil
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Введите корректную сумму"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let cacheService = CachedExchangeRateService(context: context)
        let manager = ExchangeRateManager(
            apiService: apiService,
            cacheService: cacheService
        )
        
        do {
            let exchangeRate = try await manager.getRates(base: fromCurrency)
            guard let foundRate = exchangeRate.rates[toCurrency.rawValue] else {
                errorMessage = "Курс для \(toCurrency.rawValue) не найден"
                return
            }
            self.rate = foundRate
            self.result = amountValue * foundRate
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
