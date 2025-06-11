import SwiftUI
import SwiftData
import CoreModels
import CurrencyAPI
import CurrencyDatabase

@MainActor
final class ConverterViewModel: ObservableObject {

    @AppStorage("fromCurrency") private var storedFrom: String = Currency.USD.rawValue
    @AppStorage("toCurrency")   private var storedTo:   String = Currency.RUB.rawValue

    @Published var fromCurrency: Currency {
        didSet { storedFrom = fromCurrency.rawValue }
    }
    @Published var toCurrency:   Currency {
        didSet { storedTo = toCurrency.rawValue }
    }

    init() {
        let from = Currency(rawValue: UserDefaults.standard.string(forKey: "fromCurrency") ?? "") ?? .USD
        let to = Currency(rawValue: UserDefaults.standard.string(forKey: "toCurrency") ?? "") ?? .RUB

        self._fromCurrency = Published(initialValue: from)
        self._toCurrency = Published(initialValue: to)
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
            let conversionResult = amountValue * foundRate
            self.result = conversionResult
            
            // Сохраняем запись в историю 
            let record = ConversionHistoryRecord(
                fromCurrency: fromCurrency.rawValue,
                toCurrency: toCurrency.rawValue,
                amount: amountValue,
                result: conversionResult,
                rate: foundRate
            )
            context.insert(record)
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
