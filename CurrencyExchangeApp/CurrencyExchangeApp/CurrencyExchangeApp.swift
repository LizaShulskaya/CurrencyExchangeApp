import SwiftUI
import SwiftData
import CurrencyAPI
import CurrencyDatabase
import CurrencyRateService

@main
struct CurrencyConverterApp: App {
    private let container: ModelContainer
    private let apiService: CurrencyAPIService
    private let databaseService: CurrencyDatabaseService
    private let settingsStorage: UserSettingsStorage
    private let currencyRateService: CurrencyRateServiceProvider
    private let viewModel: ConverterViewModel

    init() {
        // Контейнер для SwiftData
        self.container = try! ModelContainer(for: ExchangeRateCache.self, ConversionHistoryRecord.self)

        // Конфигурация API
        do {
            let config = try AppProperties.getConfig()
            
            // Сервисы
            self.apiService = CurrencyAPIService(apiKey: config.apiKey, baseURL: config.baseURL)
            self.databaseService = CurrencyDatabaseService(context: container.mainContext)
            self.currencyRateService = CurrencyRateServiceProvider(apiService: apiService,
                                                                   databaseService: databaseService,
                                                                   cacheTimeout: config.cacheTimeout)
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }

        // Хранилище пользовательских настроек
        self.settingsStorage = UserDefaultsSettingsStorage()

        // ViewModel со всеми зависимостями
        self.viewModel = ConverterViewModel(
            settingsStorage: settingsStorage,
            currencyRateService: currencyRateService
        )
    }

    var body: some Scene {
        WindowGroup {
            ConverterView(viewModel: viewModel)
                .modelContainer(container)
        }
    }
}
